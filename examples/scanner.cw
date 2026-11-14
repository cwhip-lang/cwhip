/*
    Demonstrate the use of handles with inline.
 */
import system as Sys

namespace scanner {
    class File {

        public:
        enum {
            END_OF_INPUT = -2,
            END_OF_FILE,
        }

        handle fh
        int64 line
        int64 col
        strg name
        strg err
        int64 ch

        File() {}

        File(strg fname, strg mode) {
            name = fname
            open(fname, mode)
        }

        void open(strg fname, strg mode) {

            inline(handle fh, strg err, strg fname, strg mode) {
                *fh = cwhip_file_open(NULL, *fname, *mode);
                *err = cwhip_system_last_error(NULL);
            }

            if(err.length > 0) {
                raise(Exception(format("Cannot open file: \"{}\": {}", fname, err)))
            }
        }

        void close() {
            inline(handle fh) {
                cwhip_file_close(NULL, *fh);
            }
        }

        int64 get_char() {
            return(ch)
        }

        int64 consume_char() {
            if(ch != -1) {
                if(ch == 0x0a) {
                    line += 1
                    col = 1
                }
                else {
                    col += 1
                }

                inline(strg err, handle fh, int64 ch) {
                    FILE* stream = (FILE*)*fh;
                    *ch = fgetc(stream);
                    *err = cwhip_system_last_error(NULL);
                }
            }
            else {
                ch = -2
            }

            return(ch)
        }

    }

    class FileStack {

        public:
        list stack 
        int64 index

        FileStack() {
            index = -1
            stack = []
        }

        void open(strg fname, strg mode) {
            File fp(fname, mode)
            index += 1
            stack.append(fp)
            fp.consume_char()
        }

        # silently fail if stack is empty
        void close() {
            if(index >= 0) {
                (stack[index] as File).close()
                index -= 1
            }
            # Do nothing
        }

        int64 get_line() {
            if(index >= 0) {
                return((stack[index] as File).line) 
            }
            else {
                return(File.END_OF_FILE)
            }
        }
        
        int64 get_col() {
            if(index >= 0) {
                return((stack[index] as File).col) 
            }
            else {
                return(File.END_OF_FILE)
            }
        }
        
        strg get_name() {
            if(index >= 0) {
                return((stack[index] as File).name)
            }
            else {
                return(null)
            } 
        }

        int64 get_char() {
            if(index >= 0) {
                return((stack[index] as File).ch)
            }
            else {
                return(File.END_OF_INPUT)
            } 
        }

        int64 consume_char() {
            return((stack[index] as File).consume_char())
        }

        void print_char() {
            int64 c = get_char()
            inline(int64 c) {
                switch(*c) {
                    case -1:
                        printf("END OF FILE");
                        break;
                    case -2:
                        printf("END OF INPUT");
                        break;
                    default:
                        printf("%c", (char)*c);
                        break;
                }
            }
        }
    }

} /* scanner */

start {
    
    scanner.FileStack fstk()

    try {
        fstk.open("input_test.txt", "r")
        print(format("opened file: {}\n", fstk.get_name()))
    }
    except() as msg {
        print(format("open input file failed: {}\n", msg))
        raise()
    }

    int64 ch = fstk.get_char()
    do {
        fstk.print_char()
        
        # The next line throws a RT error because END_OF_FILE and END_OF_INPUT
        # are not ASCII characters.
        # print(format("{:c}", ch))

        ch = fstk.consume_char()
        if(ch == scanner.File.END_OF_FILE) {
            fstk.close()
        }
    } while(ch != scanner.File.END_OF_INPUT) 

    print("\n")
}
