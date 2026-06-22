const dates = [new Date().getTime(), new Date().getTime()];
console.log(new Date(Math.min(...dates)).toISOString());
