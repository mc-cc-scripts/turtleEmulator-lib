local spath =
    debug.getinfo(1,'S').source:sub(2):gsub("/+", "/"):gsub("[^/]*$","")
package.path = spath.."?.lua;"
    ..spath.."inventory/?.lua;"
    ..package.path
require(spath.."TestSuite-lib/ccPackage")