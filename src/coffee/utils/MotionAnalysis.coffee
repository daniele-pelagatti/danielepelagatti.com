class MotionAnalysis
    # results 
    rotation            : null
    acceleration        : null
    gravity             : null
    invertX             : 1
    invertY             : 1
    invertZ             : 1
    addY                : 0
    status              : null

    constructor:->

        @rotation           = {x: 0, y: 0, z: 0}
        @acceleration       = {x: 0, y: 0, z: 0}
        @gravity            = {x: 0, y: 0, z: 0}

        # @browser = BrowserDetect.browser
        # @browserVersion = BrowserDetect.version

        @invertY = -1
        @addY = -360

        # if @browser == "Firefox"
        #     @invertX = @invertZ = -1
        #     @invertY = 1
        #     @addY = 0
        

        window.addEventListener('deviceorientation',        @onGyroscopeData, true) if window.DeviceOrientationEvent
        window.addEventListener('devicemotion',             @onAccelerometerData , true) if window.DeviceMotionEvent
        window.addEventListener('compassneedscalibration ', @onCompassNeedsCalibration , true);

        # @status = $("<p id=\"motionstatus\"></p>")
        # $('body').append(@status)

        @

    onCompassNeedsCalibration:(e)=>
        console.log "COMPASS NEEDS CALIBRATION"
        @

    onAccelerometerData:(e)=>
        # @deviceUpsideDown =  if e.accelerationIncludingGravity.z < 0 then 1 else -1

        @gravity.x = -e.accelerationIncludingGravity.x  * @invertX # device's X
        @gravity.y = e.accelerationIncludingGravity.z   * @invertY # device's Z
        @gravity.z = -e.accelerationIncludingGravity.y  * @invertZ # device's Y


        @acceleration.x = e.rotationRate.alpha  * @invertX # device's Z
        @acceleration.y = e.rotationRate.gamma  * @invertY # device's Y
        @acceleration.z = e.rotationRate.beta   * @invertZ # device's X
        @

    onGyroscopeData:(e)=>
        @rotation.x         = -e.beta  * @invertX  # device's X
        @rotation.y         = (e.alpha + @addY) * @invertY  # device's Z
        @rotation.z         = -e.gamma * @invertZ  # device's Y
        

        # if e.webkitCompassHeading?
        #     @rotation.absolute = true
        #     @rotation.y = e.webkitCompassHeading * @deviceUpsideDown
        # else
        @rotation.absolute = if e.absolute? then e.absolute else false
        @

    wrapAngle:(value)->
        # wrap a value between -180 and 180
        value = value % 360;
        return if value <= 180 then value else value - 360;