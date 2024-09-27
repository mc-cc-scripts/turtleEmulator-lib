-- get the current path to this file
local spath =
    debug.getinfo(1,'S').source:sub(2):gsub("/+", "/"):gsub("[^/]*$","")
-- add the path to the package path
package.path = spath.."?.lua;"
    ..spath.."inventory/?.lua;"
    ..spath.."peripherals/?.lua;"
    ..spath.."defaultBehaviour/?.lua;"
    ..package.path
-- require the package of the test suite
require(spath.."TestSuite-lib/ccPackage")