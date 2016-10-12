wpi = require "wiring-pi"

pin = 1
waitTime = 2

wpi.setup "wpi"
wpi.pinMode pin, wpi.OUTPUT

# console.log wpi

wpi.softToneCreate pin

start = ->
  wpi.softToneWrite pin, 349*4
stop = ->
  wpi.softToneWrite pin, 0
  # wpi.softToneStop pin

start()
setTimeout stop, 300

