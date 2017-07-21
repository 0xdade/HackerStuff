/*
Using Jenkins Script Console, this is a (pretty lame) shell to interact with the server itself
*/

def command = '[YOUR COMMAND]'
def sout = new StringBuffer(), serr = new StringBuffer()
def proc = command.execute()
proc.consumeProcessOutput(sout, serr)
proc.waitForOrKill(10000)
println "out> $sout"
println "err> $serr"
