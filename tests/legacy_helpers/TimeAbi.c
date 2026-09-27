/* Compile the real helper to reject a return type wider than INTEGER*4. */
#include "time.c"
_Static_assert(sizeof(time_()) == 4, "TIME result must match INTEGER*4");
