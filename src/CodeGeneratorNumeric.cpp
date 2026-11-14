#include "cwhip/CodeGenerator.hpp"
#include "cwhip/NumericType.hpp"
#include "cwhip/Diagnostic.hpp"

#include <algorithm>
#include <cmath>
#include <iomanip>
#include <sstream>

namespace cwhip {
namespace {
std::string powerOfTwo(unsigned exponent, bool negative = false) {
    std::ostringstream text;
    text << std::scientific << std::setprecision(17)
         << (negative ? -1.0 : 1.0) * std::ldexp(1.0, exponent);
    return text.str();
}
}

std::string CodeGenerator::numericAbiExtension(const std::string& type) const {
    if (type == "bool") return "zeroext";
    const auto* numeric = numericType(type);
    if (!numeric || !isIntegerType(type) || numeric->width >= 32) return "";
    if (targetTriple_.find("x86_64") == 0 || targetTriple_.find("i386") == 0 ||
        targetTriple_.find("i686") == 0)
        return numeric->category == NumericCategory::SignedInteger ? "signext" : "zeroext";
    return "";
}

std::string CodeGenerator::abiParameterType(const std::string& type) const {
    const auto extension = numericAbiExtension(type);
    return llvmType(type) + (extension.empty() ? "" : " " + extension);
}

void CodeGenerator::emitConstWriteGuard(const Binding& binding, const std::string& name,
                                       const SourceLocation& location) {
    if (binding.constFlagAddress.empty()) return;
    const auto written = newTemporary();
    instructions_ += "  " + written + " = load i1, ptr " + binding.constFlagAddress + "\n";
    emitNumericFailureIf(written, "assignment to const variable '" + name + "'", location);
}

void CodeGenerator::emitNumericFailureIf(const std::string& condition,
                                         const std::string& message,
                                         const SourceLocation& location) {
    const auto failure = freshLabel("numeric.failure");
    const auto success = freshLabel("numeric.success");
    instructions_ += "  br i1 " + condition + ", label %" + failure +
                     ", label %" + success + "\n" + failure + ":\n"
                     "  call void @cwhip_exception_raise(ptr " + internString(message) +
                     ", i64 " + std::to_string(message.size()) + ", ptr " +
                     internString(location.file) + ", i64 " +
                     std::to_string(location.file.size()) + ", i64 " +
                     std::to_string(location.line) + ", i64 " +
                     std::to_string(location.column) + ")\n"
                     "  unreachable\n" + success + ":\n";
}

CodeGenerator::Value CodeGenerator::convertNumericValue(
    Value value, const std::string& target, const SourceLocation& location) {
    if (target == value.type) return value;
    const auto* sourceType = numericType(value.type);
    const auto* targetType = numericType(target);
    const auto sourceLlvm = llvmType(value.type);
    const auto targetLlvm = llvmType(target);
    const auto result = newTemporary();
    if (target == "bool" && sourceType) {
        instructions_ += "  " + result +
            (isFloatingType(value.type) ? " = fcmp une " : " = icmp ne ") +
            sourceLlvm + " " + value.operand +
            (isFloatingType(value.type) ? ", 0.0\n" : ", 0\n");
    } else if (value.type == "bool" && targetType) {
        instructions_ += "  " + result +
            (isFloatingType(target) ? " = uitofp i1 " : " = zext i1 ") +
            value.operand + " to " + targetLlvm + "\n";
    } else if (!sourceType || !targetType) {
        throw DiagnosticError(location, "invalid numeric conversion from " +
                              value.type + " to " + target);
    } else if (isIntegerType(value.type) && isIntegerType(target)) {
        if (sourceType->width == targetType->width)
            return {target, value.operand, value.nullFlag};
        const auto opcode = sourceType->width > targetType->width ? "trunc" :
            sourceType->category == NumericCategory::SignedInteger ? "sext" : "zext";
        instructions_ += "  " + result + " = " + opcode + " " + sourceLlvm + " " +
                         value.operand + " to " + targetLlvm + "\n";
    } else if (isIntegerType(value.type)) {
        instructions_ += "  " + result +
            (sourceType->category == NumericCategory::SignedInteger ? " = sitofp " :
                                                                     " = uitofp ") +
            sourceLlvm + " " + value.operand + " to " + targetLlvm + "\n";
    } else if (isFloatingType(target)) {
        instructions_ += "  " + result +
            (sourceType->width > targetType->width ? " = fptrunc " : " = fpext ") +
            sourceLlvm + " " + value.operand + " to " + targetLlvm + "\n";
    } else {
        const auto rounded = newTemporary();
        const auto intrinsic = "llvm.trunc.f" + std::to_string(sourceType->width);
        if (declaredInlineSymbols_.emplace(intrinsic).second)
            inlineDeclarations_ += "declare " + sourceLlvm + " @" + intrinsic +
                                   "(" + sourceLlvm + ")\n";
        instructions_ += "  " + rounded + " = call " + sourceLlvm + " @" + intrinsic +
                         "(" + sourceLlvm + " " + value.operand + ")\n";
        const bool signedTarget = targetType->category == NumericCategory::SignedInteger;
        const unsigned exponent = targetType->width - (signedTarget ? 1 : 0);
        const auto lower = newTemporary();
        const auto upper = newTemporary();
        const auto valid = newTemporary();
        const auto invalid = newTemporary();
        instructions_ += "  " + lower + " = fcmp oge " + sourceLlvm + " " + rounded +
                         ", " + (signedTarget ? powerOfTwo(exponent, true) : "0.0") + "\n"
                         "  " + upper + " = fcmp olt " + sourceLlvm + " " + rounded +
                         ", " + powerOfTwo(exponent) + "\n"
                         "  " + valid + " = and i1 " + lower + ", " + upper + "\n"
                         "  " + invalid + " = xor i1 " + valid + ", true\n";
        emitNumericFailureIf(invalid, "invalid numeric conversion", location);
        instructions_ += "  " + result + (signedTarget ? " = fptosi " : " = fptoui ") +
                         sourceLlvm + " " + rounded + " to " + targetLlvm + "\n";
    }
    return {target, result, value.nullFlag};
}

CodeGenerator::Value CodeGenerator::emitNumericComparison(
    const std::string& operation, Value left, Value right,
    const SourceLocation& location) {
    const auto result = newTemporary();
    const bool floating = isFloatingType(left.type) || isFloatingType(right.type);
    std::string irType;
    if (floating) {
        const auto common = *commonNumericType(left.type, right.type);
        left = convertNumericValue(left, common, location);
        right = convertNumericValue(right, common, location);
        irType = llvmType(common);
    } else {
        const auto* lhs = numericType(left.type);
        const auto* rhs = numericType(right.type);
        const unsigned width = std::max(lhs->width, rhs->width) + 1;
        irType = "i" + std::to_string(width);
        const auto extend = [&](Value value) {
            const auto extended = newTemporary();
            instructions_ += "  " + extended +
                (numericType(value.type)->category == NumericCategory::SignedInteger
                     ? " = sext " : " = zext ") +
                llvmType(value.type) + " " + value.operand + " to " + irType + "\n";
            return extended;
        };
        left.operand = extend(left);
        right.operand = extend(right);
    }
    const auto predicate = floating
        ? operation == "==" ? "oeq" : operation == "!=" ? "une" :
          operation == "<" ? "olt" : operation == "<=" ? "ole" :
          operation == ">" ? "ogt" : "oge"
        : operation == "==" ? "eq" : operation == "!=" ? "ne" :
          operation == "<" ? "slt" : operation == "<=" ? "sle" :
          operation == ">" ? "sgt" : "sge";
    instructions_ += "  " + result + (floating ? " = fcmp " : " = icmp ") +
                     predicate + " " + irType + " " + left.operand + ", " +
                     right.operand + "\n";
    return {"bool", result};
}

} // namespace cwhip
