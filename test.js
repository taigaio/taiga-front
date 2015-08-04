var startTime = new Date().getTime();
var duration = 500;
var from = 2;
var to = 10;
var delta = to - from;

function next() {
    var elapsed = new Date().getTime() - startTime;
    var factor = Math.min(elapsed / duration, 1);

    console.log(from + delta * factor);
}


setInterval(function(){
    next();
}, 50);
