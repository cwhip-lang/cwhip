/*
 * tests/functional/positive/positive_inline_headers.cw
 *
 * Checks inline headers.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    bool ok = false
    inline (bool ok) {
        char source[] = "hello";
        char destination[sizeof source];
        memcpy(destination, source, sizeof source);
        errno = 0;
        char *end = NULL;
        long number = strtol("42", &end, 10);
        int converted = number == 42 && *end == '\0' && errno == 0;
        errno = 0;
        (void)strtol("99999999999999999999999999999999999999999999999999999", NULL, 10);
        int overflow = errno == ERANGE;
        FILE *file = tmpfile();
        *ok = file != NULL && strcmp(destination, "hello") == 0 &&
              isalpha((unsigned char)'a') && toupper((unsigned char)'a') == 'A' &&
              converted && overflow &&
              CHAR_BIT == 8 && INT64_MAX > INT32_MAX && UINT64_MAX > UINT32_MAX &&
              getpid() > 0 && STDOUT_FILENO == 1;
        if (file) fclose(file);
    }
    print(ok)
}
