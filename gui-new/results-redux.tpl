<!doctype html>
<html lang="us">
    <head>
        <meta charset="utf-8">
        <title>MongoDB Performance Benchmarks</title>
        <link href="static/css/jquery-ui-1.10.1.custom.min.css" rel="stylesheet">
        <link rel="stylesheet" href="static/css/page.css">
        <link href="static/css/perf_style.css" rel="stylesheet">
        <script type="text/javascript" src="static/js/jquery-1.9.1.min.js"></script>
        <script type="text/javascript" src="static/js/jquery-ui-1.10.1.custom.min.js"></script>
        <script type="text/javascript" src="static/js/perf_lib.js"></script>
        <script type="text/javascript" src="static/js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" src="static/js/jquery.flot.min.js"></script>
        <script>
            $(document).ready(function(){
                $('table').dataTable({
                        "bPaginate": false,
                        "bLengthChange": false,
                        "bFilter": false,
                        "bInfo": false,
                        "bAutoWidth": true
                    });
                });
        </script>
    </head>
    <body>
        <h1>MongoDB Benchmark Results (<a href="/">Home</a>)</h1>
        % platforms = ' '.join(request.GET.getall('platforms'))
        % versions = ' '.join(request.GET.getall('versions'))
        % labels = ' '.join(request.GET.getall('labels'))
        % dates = ' '.join(request.GET.getall('dates'))
        % home = ' '.join(request.GET.getall('home'))
        % metric = request.GET.get('metric', 'ops_per_sec')
        % multidb = request.GET.get('multidb', '0')
        % limit = request.GET.get('limit', '10')
        % start = request.GET.get('start', '')
        % end = request.GET.get('end', '')

        <form name="query-form" id="query-form" action="/results" method="get">
          <fieldset class="fields">
            <div class="floatleft">
              <h2>
                From: <input type="text" size="6" name="start" class="datepicker" />
              </h2>
              <h2>
                To: <input type="text" size="6" name="start" class="datepicker" />
              </h2>
              <h2>Labels</h2>
              % alllabels = info['labels']
              %for label in alllabels:
              <input type="checkbox" name="labels" value={{label}}>{{label}}<br>
              %end
              <h2>Limit</h2>
              <input type="text" name="limit" size="2" value="5" />
            </div>
            <div class="floatcenter">
              <h2>Platforms</h2>
                % allplatforms = info['allplatforms']
                %for platform in allplatforms:
                <input type="checkbox" name="platforms" value={{platform}}>{{platform}}<br>
                %end
              <h2>Versions</h2>
                % allversions = info['versions']
                %for version in allversions:
                <input type="checkbox" name="versions" value={{version}}>{{versions}}<br>
                %end
              <h2>MultiDB</h2>
                <input type="checkbox" name="multidb" value="0">MultiDB<br>
            </div>
          </fieldset>
        </form>
        %import urllib
        %for k, (outer_result, flot_data) in enumerate(zip(results, flot_results)):
        <h2 id="{{outer_result['name']}}"><a href="https://github.com/search?q={{outer_result['name'][outer_result['name'].rfind(":") + 1:]}}+path%3Abenchmark.cpp+repo%3Amongodb%2Fmongo-perf&amp;type=Code&amp;ref=searchresults" target="_blank">{{outer_result['name']}}</a></h2>
        <table class="display">
            <thead>
                <tr>
                    <th>Num</th>
                    <th>Label</th>
                    <th>Platform</th>
                    <th>Version</th>
                    <th>Date</th>
                    <th>Commit</th>
                    %for thread in threads:
                    <th>{{thread}} thread{{'' if thread == 1 else 's'}}</th>
                    %end
                </tr>
            </thead>
            <tbody>
                %for i, result in enumerate(outer_result['results']):
                %host_keys = ['date', 'label', 'version']
                %host = {}
                %for key in host_keys:
                %host[key] = result[key]
                %end
                %host = urllib.urlencode(host)
                <tr>
                    <td>{{i+1}}</td>
                    <td><a href="host?{{host}}">{{result['label']}}</a></td>
                    <td>{{result['platform']}}</td>
                    <td>{{result['version']}}</td>
                    <td>{{result['date']}}</td>
                    <td><a href="https://github.com/mongodb/mongo/commit/{{result['commit']}}" target="_blank">{{result['commit'][:7]}}</a></td>
                    %for thread in threads:
                    <td>{{"{0:.2f}".format(result.get(str(thread), {metric:'--'})[metric])}}</td>
                    %end
                </tr>
                %end
            </tbody>
        </table>
        <br/>
        <div id="legendContainer_{{k}}" style="background-color:#fff;padding:2px;margin-bottom:8px;border-radius: 3px 3px 3px 3px;border:1px solid #E6E6E6;display:inline-block;margin:0 auto;width:600px;float:right"></div>
        <div id="flot_{{k}}" style="width:600px;height:300px;"></div>
        <div id="chart_{{k}}" data-dump="{{flot_data}}"></div>
        <div style="height:50px"></div>
        <script>
            $(function(){
                var data = $('#chart_{{k}}').data('dump');
                var div = $('#flot_{{k}}')
                var options =  {
                        grid: { hoverable: true, backgroundColor: { colors: ["#eceadf", "#d9d6c4"] } }, 
                        series: { lines: { show: true }, points: { show: true } },
                        legend: { show: true, position: "nw", backgroundOpacity: 0,
                        container: $("#legendContainer_{{k}}"), noColumns: 2 },
                        xaxis: {ticks : {{threads}} },
                        yaxis: {min : 0},
                        tooltip: true
                    }
                $.plot(div, data, options);

            function showTooltip(x, y, contents) {
                $('<div id="tooltip_{{k}}">' + contents + '</div>').css( {
                    position: 'absolute',
                    display: 'none',
                    top: y + 5,
                    left: x + 5,
                    border: '1px solid #fdd',
                    padding: '2px',
                    'background-color': '#fee',
                    opacity: 0.80
                }).appendTo("body").fadeIn(200);
            };

            var previousPoint = null;
            div.bind("plothover", function (event, pos, item) {
                $("#x").text(pos.x.toFixed(2));
                $("#y").text(pos.y.toFixed(2));

                if (item) {
                    if (previousPoint != item.dataIndex) {
                        previousPoint = item.dataIndex;
                        
                        $("#tooltip_{{k}}").remove();
                        var x = item.datapoint[0].toFixed(2),
                            y = item.datapoint[1].toFixed(2);
                        
                        showTooltip(item.pageX, item.pageY, item.series.label + " ( " + y + " ) ");
                    }
                }
                else {
                    $("#tooltip_{{k}}").remove();
                    previousPoint = null;            
                }
            });


            });
        </script>
        <hr>
        %end
    </body>
</html>
%# vim: set ft=html: