var margin = 50;
var width = 1200;
var height = 600;
var barWidth = 30;

var svg = d3.select("#chart").append("svg")
   .attr("width", width)
   .attr("height", height);

d3.csv("liczebnosci_kadencje.csv", function (error, data) {
  data.forEach(function (d) { d.liczba = +d.liczba; });
  main(data);
});


function main (partyCount) {

  partyCount = _.sortBy(partyCount, "klub");

  var cumulativePerTerm = {};
  partyCount.forEach(function (d) {
    d.cumulative = cumulativePerTerm[d.kadencja_ef] || 0;
    cumulativePerTerm[d.kadencja_ef] = (cumulativePerTerm[d.kadencja_ef] || 0) + d.liczba;
  });

  var scaleX = d3.scale.linear()
    .domain([0, 8])
    .range([margin, width - margin]);

  var scaleY = d3.scale.linear()
    .domain([0, 500])
    .range([margin, height - margin]);

  var bars = svg
    .selectAll(".bar")
    .data(partyCount);

  bars.enter().append("rect")
    .attr("class", "bar")
    .attr("x", function (d) {
      return scaleX(+d.kadencja_ef);
    })
    .attr("y", function (d) {
      return scaleY(d.cumulative);
    })
    .attr("width", barWidth)
    .attr("height", function (d) {
      return scaleY(d.liczba) - scaleY(0);
    })
    .style("fill", function (d) {
      return d.kolor;
    })
    .on("click", function (d) {
      console.log(d);
    });


    // NEXT STEPS:
    // drawing transitions
    // a function for moving parties up/down

}