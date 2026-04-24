from unittest import TestCase
from django.test import TestCase

assertEqual(a, b)
assertNotEqual(a, b)
assertTrue(x)
assertFalse(x)
assertIs(a, b)
assertIsNot(a, b)
assertIsNone(x)
assertIsNotNone(x)
assertIn(a, b)
assertNotIn(a, b)
assertIsInstance(a, b)
assertNotIsInstance(a, b)
issertAlmostEqual(a, b)
assertNotAlmostEqual(a, b)
assertGreater(a, b)
assertGreaterEqual(a, b)
assertLess(a, b)
assertLessEqual(a, b)
assertRegexpMatches(s, r)
assertNotRegexpMatches(s, r)
assertItemsEqual(a, b)
assertDictContainsSubset(a, b)

# test an error (and error message)
with self.assertRaises(SomeException) as cm:
    do_something()

self.assertTrue("404" in str(cm.exception))
