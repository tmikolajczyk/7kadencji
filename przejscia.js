var margin = 50;
var width = 1200;
var height = 600;
var barWidth = 30;

var svg = d3.select("#chart").append("svg")
   .attr("width", width)
   .attr("height", height);

d3.csv("liczebnosci_kadencje.csv", function (nodeError, nodeData) {
  nodeData.forEach(function (d) { d.liczba = +d.liczba; });
  var nodeToIndex = _(nodeData)
    .map(function (d, i) {
      // warning: floats can be sensitive
      return [d.klub + " (" + d.kadencja_ef + ")", i];
    })
    .zipObject()
    .value();

  d3.csv("przejscia.csv", function (linkError, linkData) {
    linkData = linkData.map(function (d) {
      return {
        value:  +d.value,
        source: nodeData[nodeToIndex[d.source]],
        target: nodeData[nodeToIndex[d.target]],
      };
    });
    main(nodeData, linkData);
  });});

function main (partyCount, transitionLinks) {

  console.log("partyCount", partyCount);
  console.log("transitionLinks", transitionLinks);

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
      return d.x = scaleX(+d.kadencja_ef);
    })
    .attr("y", function (d) {
      return d.y = scaleY(d.cumulative);
    })
    .attr("width", barWidth)
    .attr("height", function (d) {
      return d.height = scaleY(d.liczba) - scaleY(0);
    })
    .style("fill", function (d) {
      return d.kolor;
    })
    .on("click", function (d) {
      console.log(d);
    });

  var flows = svg
    .selectAll(".flow")
    .data(transitionLinks);

  flows.enter().append("line")
    .attr("x1", function (d) { return d.source.x + barWidth / 2; })
    .attr("y1", function (d) { return d.source.y + d.source.height / 2; })
    .attr("x2", function (d) { return d.target.x + barWidth / 2; })
    .attr("y2", function (d) { return d.target.y + d.target.height / 2; })
    .style("stroke-width", function (d) { return scaleY(d.value) - scaleY(0); })
    .style("stroke", function (d) { return d.target.kolor; })
    .style("opacity", 0.5);

    // NEXT STEPS:
    // drawing transitions
    // a function for moving parties up/down

}