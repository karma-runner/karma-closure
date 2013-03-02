goog.require('main');

/**
 * main
 *   -> a
 *     -> b
 *     -> c
 *       -> d
 *   -> b
 *   -> e
 */

describe('main', function() {
  it('should call through a(), b() and sum', function() {
    expect(main(1, 2)).toBe(7);
  })
});
