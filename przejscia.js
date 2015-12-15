var margin = 50;
var width = 1200;
var height = 600;
var barWidth = 10;

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

  var tooltip = new Tooltip("#chart");

  partyCount = _.sortBy(partyCount, "klub");

  var t;

  var cumulativePerTerm = {};
  partyCount.forEach(function (d) {
    d.cumulative = cumulativePerTerm[d.kadencja_ef] || 0;
    cumulativePerTerm[d.kadencja_ef] = (cumulativePerTerm[d.kadencja_ef] || 0) + d.liczba;
  });

  cumulativePerTerm = {};
  _.sortBy(transitionLinks, "source.klub")
    .forEach(function (d) {
      t = d.target.klub + " " + d.target.kadencja_ef;
      d.cumulativeRight = cumulativePerTerm[t] || 0;
      cumulativePerTerm[t] = (cumulativePerTerm[t] || 0) + d.value;
    });

  cumulativePerTerm = {};
  _.sortBy(transitionLinks, "target.klub")
    .forEach(function (d) {
      t = d.source.klub + " " + d.source.kadencja_ef;
      d.cumulativeLeft = cumulativePerTerm[t] || 0;
      cumulativePerTerm[t] = (cumulativePerTerm[t] || 0) + d.value;
    });

  var maxPoslow = d3.max(partyCount, function (d) { return d.cumulative});

  var scaleX = d3.scale.linear()
    .domain([0, 9])
    .range([margin, width - margin]);

  var scaleY = d3.scale.linear()
    .domain([0, maxPoslow])
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
    })
    .on("mouseover", function (d) {
      d3.select(this).style("opacity", 0.9);
      tooltip.show(
        d.kadencja_ef + " kadencja<br>" +
        d.klub + "<br>" +
        d.liczba + " posłów");
    })
    .on("mouseout", function (d) {
      d3.select(this).style("opacity", null);
      tooltip.out();
    });

  var flows = svg
    .selectAll(".flow")
    .data(transitionLinks);

  var controlDist = 20;

  // warning: it mostly works, but has a few pathologies
  // either conditions for fill-not-stroke for broad transitions
  // or very thin barWidth
  flows.enter().append("path")
    .attr("class", "flow")
    .attr("d", function (d) {
      var x1 = d.source.x + barWidth;
      var y1 = d.source.y + scaleY(d.cumulativeLeft) - scaleY(0) + (scaleY(d.value) - scaleY(0)) / 2;
      var x2 = d.target.x;
      var y2 = d.target.y + scaleY(d.cumulativeRight) - scaleY(0) + (scaleY(d.value) - scaleY(0)) / 2;
      return "M" + x1 + " " + y1
           + "C" + (x1 + controlDist) + "," + y1
           + " " + (x2 - controlDist) + "," + y2
           + " " + x2 + "," + y2;
    })
    .style("stroke", function (d) { return d.target.kolor; })
    .style("stroke-width", function (d) { return scaleY(d.value) - scaleY(0); })
    .on("mouseover", function (d) {
      d3.select(this).style("opacity", 0.7);
      tooltip.show(
        "przejścia " + d.source.kadencja_ef + "-" + d.target.kadencja_ef + " kadencji<br>" +
        "z: " + d.source.klub + "<br>" +
        "do: " + d.target.klub + "<br>" +
        d.value + " posłów");
    })
    .on("mouseout", function (d) {
      d3.select(this).style("opacity", null);
      tooltip.out();
    });

    svg.selectAll(".kadencja")
      .data(_.range(1, 9))
      .enter()
      .append("text")
        .attr("class", "kadencja")
        .attr("x", function (d) { return scaleX(d + 0.25) + barWidth / 2; })
        .attr("y", height - margin + 20)
        .text(function (d) { return "" + d + ". kadencja"});

    var drag = d3.behavior.drag()
      .origin(function(d) { return d; })
      .on("dragstart", function (d) {
        d.dragged = true;
        d3.select(this)
          .transition().duration(500)
            .attr("x", d.x += barWidth);
      })
      .on("drag", function (d) {
        d3.select(this)
          .attr("y", d.y = d3.event.y);
      })
      .on("dragend", function (d) {
        d3.select(this)
          .transition().duration(500)
            .attr("x", d.x -= barWidth);

        _(partyCount)
          .filter(function (c) { return c.kadencja_ef === d.kadencja_ef})
          .forEach(function (c) { c.order = c.dragged ? c.y : c.y + c.height / 2})
          .sortBy("order")
          .reduce(function (a, b) {
            b.cumulative = a;
            return a + b.liczba;
          }, 0);

        bars.attr("y", function (c) {
          return c.y = scaleY(c.cumulative);
        });

        cumulativePerTerm = {};
        _(transitionLinks)
          .sortBy("source.y")
          .forEach(function (c) {
            t = c.target.klub + " " + c.target.kadencja_ef;
            c.cumulativeRight = cumulativePerTerm[t] || 0;
            cumulativePerTerm[t] = (cumulativePerTerm[t] || 0) + c.value;
          })
          .value();

        cumulativePerTerm = {};
        _(transitionLinks)
          .sortBy("target.y")
          .forEach(function (c) {
            t = c.source.klub + " " + c.source.kadencja_ef;
            c.cumulativeLeft = cumulativePerTerm[t] || 0;
            cumulativePerTerm[t] = (cumulativePerTerm[t] || 0) + c.value;
          })
          .value();

        flows.attr("d", function (c) {
          var x1 = c.source.x + barWidth;
          var y1 = c.source.y + scaleY(c.cumulativeLeft) - scaleY(0) + (scaleY(c.value) - scaleY(0)) / 2;
          var x2 = c.target.x;
          var y2 = c.target.y + scaleY(c.cumulativeRight) - scaleY(0) + (scaleY(c.value) - scaleY(0)) / 2;
          return "M" + x1 + " " + y1
               + "C" + (x1 + controlDist) + "," + y1
               + " " + (x2 - controlDist) + "," + y2
               + " " + x2 + "," + y2;
        });

        d.dragged = false;
      })

    bars.call(drag);

}