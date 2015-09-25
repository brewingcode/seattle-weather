units = null

init = ->
  setHeight = -> $('#graph').height $('#graph').width() * 0.55
  setHeight()
  $(window).resize -> setHeight()

  makeGraph()

makeGraph = ->
  $.getJSON 'data.json', (data) ->
    options =
      xaxis:
        mode: 'time'
        tickFormatter: (val) ->
          offset = moment(val).utcOffset()
          moment(val - offset*60000).format('ddd MMM D h:mma')
      grid:
        hoverable: true

    graphdef = []
    units = {}

    for k, v of data
      if k is 't'
        continue

      units[k] = v[0]
      graphdef.push
        label: k
        data: _.map _.zip(data.t, v[1]), (p) ->
          offset = moment(p[0]).utcOffset()
          [moment(p[0]).valueOf() + offset*60000, p[1]]

    plot = $.plot $('#graph'), graphdef, options
    $('#graph').bind 'plothover', makeTooltip

makeTooltip = (event, pos, item) ->
  if item and units
    x = item.datapoint[0]
    y = item.datapoint[1]
    offset = moment(x).utcOffset()
    thisTime = moment(x - offset*60000).format('ddd MMM D h:mma')
    unit = units[item.series.label]
    $('#tooltip').html("#{thisTime}: #{y}#{unit}").css
      top: item.pageY + 5
      left: item.pageX + 5
      'border-color': item.series.color
    .fadeIn 200
  else
    $('#tooltip').hide()

init()
