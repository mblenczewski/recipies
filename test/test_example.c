#include "mbs_test.h"

TEST(test_example) {
	int a = 42;

	ASSERT(a == 42, "a must be equal to 42");
	ASSERT_NE(a == 24, "a cannot be equal to 24");

	// FAIL();

	PASS();
}

// example of including a set of test cases
int main(void) {
	TEST_BEGIN();

	TEST_RUN(test_example);

	TEST_END();
}
