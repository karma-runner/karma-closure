goog.provide('main');

goog.require('a');
goog.require('b');


main = function(one, two) {
  return a(one) + b(two);
};
