/*
 * examples/network.cw
 *
 * Two-layer network: tanh hidden units and a sigmoid output. Trains by
 * stochastic gradient descent on binary cross-entropy. Default data is XOR.
 * Pass a CSV of numeric columns whose last column is the target:
 * ./build/network examples/xor.csv.
 *
 * Created: 2026-10-23
 * Author: chuck
 *
 * Changelog:
 *   2026-10-23  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import math as MathLib
import system as Sys

/*
 * Dataset is a class, used by this example.
 *
 * Its methods include constructor, add, useXor, load, width, features.
 */
class Dataset {
    public:
    list rows

    /*
     * Constructs a Dataset and stores rows.
     *
     * Takes no parameters.
     *
     * Returns the constructed Dataset.
     */
    Dataset() {
        rows = []
    }

    /*
     * Adds the Dataset state.
     *
     * Parameters:
     *   row — list row.
     *
     * Does not return a value.
     */
    void add(list row) {
        rows.append(row)
    }

    /*
     * Handles use xor for this Dataset.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void useXor() {
        add([0.0f64, 0.0f64, 0.0f64])
        add([0.0f64, 1.0f64, 1.0f64])
        add([1.0f64, 0.0f64, 1.0f64])
        add([1.0f64, 1.0f64, 0.0f64])
    }

    /*
     * Loads the Dataset state.
     *
     * Parameters:
     *   path — String path.
     *
     * Returns int64.
     */
    int64 load(String path) {
        Sys.File input = Sys.File(path, "r")
        list lines = input.readLines()
        input.close()

        int64 accepted = 0
        int64 lineIndex = 0
        while (lineIndex < lines.length) {
            String line = lines[lineIndex]
            line = line.trim()

            if (line.length > 0 and not line.startsWith("#")) {

                list parts = line.split(",")
                list row = []
                bool ok = true
                int64 column = 0
                while (column < parts.length) {
                    String cell = parts[column]
                    try {
                        row.append(cell.trim().toFp64())
                    }
                    except() as error {
                        ok = false
                        print(format("skipping {} ({})\n", line, error))
                    }
                    column = column + 1
                }

                if (ok and row.length >= 2) {
                    if (rows.length == 0 or row.length == width()) {
                        rows.append(row)
                        accepted = accepted + 1
                    }
                }
            }

            lineIndex = lineIndex + 1
        }

        return(accepted)
    }

    /*
     * Handles width for this Dataset.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 width() {
        if (rows.length == 0) {
            return(0)
        }
        list first = rows[0]
        return(first.length)
    }

    /*
     * Handles features for this Dataset.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 features() {
        int64 columns = width()
        if (columns == 0) {
            return(0)
        }
        return(columns - 1)
    }
}

/*
 * Network is a class, used by this example.
 *
 * Its methods include constructor, nextWeight, sigmoid, crossEntropy, forward,
 * learn, and 4 more.
 */
class Network {
    public:
    MathLib.Math math
    int64 inputCount
    int64 hiddenCount
    list hiddenWeights
    list hiddenBias
    list outputWeights
    list hidden
    fp64 outputBias
    int64 seed

    /*
     * Constructs a Network and stores math, inputCount, hiddenCount,
     * hiddenWeights.
     *
     * Parameters:
     *   inputs — int64 inputs.
     *   hiddenUnits — int64 hidden units.
     *
     * Returns the constructed Network.
     */
    Network(int64 inputs, int64 hiddenUnits) {
        math = MathLib.Math()
        inputCount = inputs
        hiddenCount = hiddenUnits
        hiddenWeights = []
        hiddenBias = []
        outputWeights = []
        hidden = []
        outputBias = 0.0
        seed = 17
        int64 weightCount = hiddenUnits * inputs
        int64 index = 0
        while (index < weightCount) {
            hiddenWeights.append(nextWeight())
            index = index + 1
        }
        index = 0
        while (index < hiddenUnits) {
            hiddenBias.append(nextWeight())
            outputWeights.append(nextWeight())
            hidden.append(0.0f64)
            index = index + 1
        }
    }

    /*
     * Handles next weight for this Network.
     *
     * Takes no parameters.
     *
     * Returns fp64.
     */
    fp64 nextWeight() {
        seed = (seed * 13 + 7) % 10007
        int64 bucket = seed % 9
        return((fp64(bucket) - 4.0) / 10.0)
    }

    /*
     * Handles sigmoid for this Network.
     *
     * Parameters:
     *   z — fp64 input value.
     *
     * Returns fp64.
     */
    fp64 sigmoid(fp64 z) {
        fp64 limited = math.clamp(z, -20.0, 20.0)
        return(1.0 / (1.0 + math.exp(0.0 - limited)))
    }

    /*
     * Handles cross entropy for this Network.
     *
     * Parameters:
     *   predicted — fp64 predicted.
     *   target — fp64 target.
     *
     * Returns fp64.
     */
    fp64 crossEntropy(fp64 predicted, fp64 target) {
        fp64 clipped = math.clamp(predicted, 0.0000001, 0.9999999)
        fp64 positive = target * math.log(clipped)
        fp64 negative = (1.0 - target) * math.log(1.0 - clipped)
        return(0.0 - (positive + negative))
    }

    /*
     * Handles forward for this Network.
     *
     * Parameters:
     *   row — list row.
     *
     * Returns fp64.
     */
    fp64 forward(list row) {

        int64 unit = 0
        while (unit < hiddenCount) {
            fp64 sum = hiddenBias[unit]
            int64 input = 0
            while (input < inputCount) {
                fp64 weight = hiddenWeights[unit * inputCount + input]
                fp64 value = row[input]
                sum = sum + weight * value
                input = input + 1
            }
            hidden[unit] = math.tanh(sum)
            unit = unit + 1
        }

        fp64 output = outputBias
        unit = 0
        while (unit < hiddenCount) {
            fp64 activation = hidden[unit]
            fp64 weight = outputWeights[unit]
            output = output + weight * activation
            unit = unit + 1
        }
        return(sigmoid(output))
    }

    /*
     * Handles learn for this Network.
     *
     * Parameters:
     *   row — list row.
     *   rate — fp64 rate.
     *
     * Does not return a value.
     */
    void learn(list row, fp64 rate) {

        fp64 predicted = forward(row)
        fp64 target = row[inputCount]
        fp64 outputError = predicted - target
        int64 unit = 0
        while (unit < hiddenCount) {
            fp64 activation = hidden[unit]
            fp64 outputWeight = outputWeights[unit]
            fp64 hiddenError = (
                    outputError * outputWeight
                    * (1.0 - activation * activation))
            int64 input = 0
            while (input < inputCount) {
                int64 index = unit * inputCount + input
                fp64 weight = hiddenWeights[index]
                fp64 value = row[input]
                hiddenWeights[index] = weight - rate * hiddenError * value
                input = input + 1
            }
            fp64 bias = hiddenBias[unit]
            hiddenBias[unit] = bias - rate * hiddenError
            outputWeights[unit] = (
                    outputWeight - rate * outputError * activation)
            unit = unit + 1
        }

        outputBias = outputBias - rate * outputError
    }

    /*
     * Handles mean loss for this Network.
     *
     * Parameters:
     *   rows — list rows.
     *
     * Returns fp64.
     */
    fp64 meanLoss(list rows) {
        if (rows.length == 0) {
            return(0.0)
        }
        fp64 total = 0.0
        int64 index = 0
        while (index < rows.length) {
            list row = rows[index]
            fp64 predicted = forward(row)
            fp64 target = row[inputCount]
            total = total + crossEntropy(predicted, target)
            index = index + 1
        }
        return(total / fp64(rows.length))
    }

    /*
     * Handles train for this Network.
     *
     * Parameters:
     *   rows — list rows.
     *   epochs — int64 epochs.
     *   rate — fp64 rate.
     *
     * Does not return a value.
     */
    void train(list rows, int64 epochs, fp64 rate) {

        int64 epoch = 0
        while (epoch < epochs) {
            if (epoch % 1000 == 0) {
                print(format("epoch {} loss {}\n", epoch, meanLoss(rows)))
            }
            int64 index = 0
            while (index < rows.length) {
                list row = rows[index]
                learn(row, rate)
                index = index + 1
            }
            epoch = epoch + 1
        }

    }

    /*
     * Saves the Network state.
     *
     * Parameters:
     *   path — String path.
     *
     * Does not return a value.
     */
    void save(String path) {
        Sys.File output = Sys.File(path, "w")
        int64 index = 0
        while (index < hiddenWeights.length) {
            fp64 value = hiddenWeights[index]
            output.writeLine(format("{}", value))
            index = index + 1
        }
        index = 0
        while (index < hiddenBias.length) {
            fp64 value = hiddenBias[index]
            output.writeLine(format("{}", value))
            index = index + 1
        }
        index = 0
        while (index < outputWeights.length) {
            fp64 value = outputWeights[index]
            output.writeLine(format("{}", value))
            index = index + 1
        }
        output.writeLine(format("{}", outputBias))
        output.close()
    }

    /*
     * Loads the Network state.
     *
     * Parameters:
     *   path — String path.
     *
     * Returns bool.
     */
    bool load(String path) {
        Sys.File input = Sys.File(path, "r")
        list lines = input.readLines()
        input.close()
        list values = []
        int64 index = 0
        while (index < lines.length) {
            String line = lines[index]
            line = line.trim()
            if (line.length > 0) {
                values.append(line.toFp64())
            }
            index = index + 1
        }
        int64 expected = (
                hiddenWeights.length + hiddenBias.length
                + outputWeights.length + 1)
        if (values.length != expected) {
            print(format(
                    "weight file has {} values, expected {}\n",
                    values.length,
                    expected))
            return(false)
        }
        int64 cursor = 0
        index = 0
        while (index < hiddenWeights.length) {
            fp64 value = values[cursor]
            hiddenWeights[index] = value
            cursor = cursor + 1
            index = index + 1
        }
        index = 0
        while (index < hiddenBias.length) {
            fp64 value = values[cursor]
            hiddenBias[index] = value
            cursor = cursor + 1
            index = index + 1
        }
        index = 0
        while (index < outputWeights.length) {
            fp64 value = values[cursor]
            outputWeights[index] = value
            cursor = cursor + 1
            index = index + 1
        }
        fp64 bias = values[cursor]
        outputBias = bias
        return(true)
    }
}

start {
    Sys.Process process = Sys.Process()
    Dataset dataset = Dataset()
    if (process.argc() >= 2) {
        String path = process.arg(1)
        int64 loaded = dataset.load(path)
        print(format("loaded {} rows from {}\n", loaded, path))
    }
    else {
        dataset.useXor()
        print("using built-in XOR rows\n")
    }
    if (dataset.rows.length == 0 or dataset.features() < 1) {
        print("no training rows\n")
        Sys.Process().exit(1)
    }

    Network network = Network(dataset.features(), 4)
    list rows = dataset.rows
    print(format("initial loss {}\n", network.meanLoss(rows)))
    network.train(rows, 5000, 2.0)
    fp64 loss = network.meanLoss(rows)
    print(format("final loss {}\n", loss))

    bool learned = true
    int64 index = 0
    while (index < rows.length) {
        list row = rows[index]
        fp64 predicted = network.forward(row)
        fp64 target = row[dataset.features()]
        fp64 gap = predicted - target
        if (gap < 0.0) {
            gap = 0.0 - gap
        }
        if (gap > 0.35) {
            learned = false
        }
        String inputs = ""
        int64 feature = 0
        while (feature < dataset.features()) {
            fp64 value = row[feature]
            if (feature > 0) {
                inputs.append(",")
            }
            inputs.append(format("{}", value))
            feature = feature + 1
        }
        print(format("{} target {} prediction {}\n", inputs, target, predicted))
        index = index + 1
    }

    String weightPath = "xor.weights"
    network.save(weightPath)

    Network restored = Network(dataset.features(), 4)
    if (restored.load(weightPath)) {
        list sample = rows[0]
        fp64 original = network.forward(sample)
        fp64 again = restored.forward(sample)
        fp64 difference = original - again
        if (difference < 0.0) {
            difference = 0.0 - difference
        }
        print(format("reloaded prediction {}\n", again))
        if (difference > 0.000001) {
            learned = false
        }
    }
    else {
        learned = false
    }

    if (learned) {
        print("result learned\n")
    }
    else {
        print("result not learned\n")
    }
}
