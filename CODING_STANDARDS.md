# Dreamcatcher Code Standards

## Python

Follows [PEP8](http://www.python.org/dev/peps/pep-0008). Enforced automatically by `black` and `ruff`.

```python
def some_function(some_argument, other_argument):
   """ Does something useful """

class SomeAmazingClass(object):
   def some_method(self, amazing_argument):
      self.some_property = amazing_argument

   def someTwistedMethod(self, amazing_argument):
      """ Twisted uses camelCase, so in Twisted apps we will too for consistency """
```

## C/C++

Logging: use `syslog(LOG_INFO|LOG_DEBUG)`. No `printf`, `fprintf`, `stderr`, `stdout`.

Format command:
```bash
# C/C++ source
indent -bad -bap -bli0 -ncdb -sc -sai -saf -saw -cli2 -cbi0 -npcs -bfda -psl -brs -bl -blf -lp -ppi 2 -l80 -nbbo -i4 -ts4 -nut *.{c,cc,cpp}

# Headers
indent -bad -bap -bli0 -ncdb -sc -sai -saf -saw -cli2 -cbi0 -npcs -brs -bl -blf -lp -ppi 2 -l80 -nbbo -i4 -ts4 -nut *.{h,hpp}
```

### C style
```c
int                        /* return type on separate line */
function_name(
    int var1,              /* lowercase, underscore-separated */
    int var2)
{
    int var_name;
    int ret;

    if (is_err())          /* space between conditional and paren */
    {                      /* braces on new line */
        ret = -1;          /* negative on error */
    }
    else
    {
        ret = 0;
    }

    return ret;
}
```

### C++ style
```cpp
class ClassName            // StudlyCaps for class names
{
    public:
        void classMethod(int var, int var2);  // camelCase for methods

    private:
        int _class_member; // underscore prefix for members
};

void
ClassName::classMethod(
        int var,
        int var2)
{
    int local_var;
}
```
