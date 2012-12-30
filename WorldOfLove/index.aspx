<%@ Page Language="C#" AutoEventWireup="true" CodeFile="index.aspx.cs" Inherits="index" %>

<!DOCTYPE html>
<html>
<head>
    <title>World Of Love</title>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <link href="css/style.css" rel="Stylesheet" />
</head>
<body>
    <div id="header">
    </div>
    <div id="mapDiv" style="width: 100%; height: 100%;">
    </div>
    <div style="width: 200px; height: 200px; position: absolute; bottom: 0; right: 0;z-index: 999;background-color: White;">
            <h2>Komentet:</h2>
            Dy fytyrat qe kalon zemra tregon vetem levizjen e zemres kurse dy fytyrat e tjera jan marr nga databaza.
        </div>
</body>
<script src="javascript/jquery-1.8.3.min.js"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyByyvahBW3RmxCf_L-dWXdscbHZD-tQfqg&sensor=true"></script>
<script type="text/javascript">
    $(document).ready(function () {

        var minZoomLevel = 2;
        var maxZoomLevel = 10;
        var centerPoint = new google.maps.LatLng(40.178873, -96.767578);
        var container;
        var map;
        var fPoints = new Array();
        var endPoints = new Array();
        var pLine;
        var marker;
        var xml;
        var points = [];
        var p = {
            start: new google.maps.LatLng(25.785053, -80.211182),
            end: new google.maps.LatLng(52.160455, 21.005859)
        };

        endPoints.push(p);
        function StringtoXML(text) {
            if (window.ActiveXObject) {
                var doc = new ActiveXObject('Microsoft.XMLDOM');
                doc.async = 'false';
                doc.loadXML(text);
            } else {
                var parser = new DOMParser();
                var doc = parser.parseFromString(text, 'text/xml');
            }
            return doc;
        }
        function putMarker() {
            $.get("ajax.aspx", function (response) {
                xml = StringtoXML(response);
                var lat = getData('latitude');
                var long = getData('longitude');
                for (var i = 0; i < lat.length; i++) {
                    var mark = new google.maps.Marker({
                        position: new google.maps.LatLng(lat[i], long[i]),
                        icon: 'images/sad_face.jpeg',
                        map: map
                    });
                }
            });
        }

        function getData(name) {
            var ret = [];
            var x = xml.getElementsByTagName(name);
            for (var i = 0; i < x.length; i++) {
                ret.push(x[i].childNodes[0].nodeValue);
            }
            return ret;
        }

        function loadMap() {

            container = document.getElementById('mapDiv');
            var myOptions = {
                center: new google.maps.LatLng(0, 0),
                zoom: minZoomLevel,
                mapTypeId: google.maps.MapTypeId.SATELLITE,
                panControl: false,
                zoomControl: true,
                mapTypeControl: true,
                scaleControl: false,
                streetViewControl: false,
                overviewMapControl: false
            };
            map = new google.maps.Map(container, myOptions);
            google.maps.event.addListener(map, 'zoom_changed', function () {
                if (map.getZoom() < minZoomLevel) map.setZoom(minZoomLevel);
                if (map.getZoom() > maxZoomLevel) map.setZoom(maxZoomLevel);
            });
            marker = new google.maps.Marker({
                position: new google.maps.LatLng(25.785053, -80.211182),
                icon: 'images/flying-heart-icon.png',
                map: map
            });
            var happy = new google.maps.Marker({
                position: new google.maps.LatLng(25.785053, -80.211182),
                icon: 'images/smileyface.gif',
                map: map
            });

            var sad = new google.maps.Marker({
                position: new google.maps.LatLng(52.160455, 21.005859),
                icon: 'images/sad_face.jpeg',
                map: map
            });
            putMarker();
            nextRoute();
        }

        function nextRoute() {
            if (endPoints.length) {
                fPoints = [];
                var p = endPoints.shift();
                plotRoute(p.start, p.end);
            }
            else {
                window.setTimeout(function () {
                    marker.setMap(map);
                    marker.setPosition(new google.maps.LatLng(25.785053, -80.211182));
                    fPoints = [];
                    var p = {
                        start: new google.maps.LatLng(25.785053, -80.211182),
                        end: new google.maps.LatLng(52.160455, 21.005859)
                    };
                    plotRoute(p.start, p.end);
                }, 2000);
            }
        }

        function plotRoute(p1, p2) {
            with (Math) {
                var lat1 = p1.lat() * (PI / 180);
                var lon1 = p1.lng() * (PI / 180);
                var lat2 = p2.lat() * (PI / 180);
                var lon2 = p2.lng() * (PI / 180);

                var d = 2 * asin(sqrt(pow((sin((lat1 - lat2) / 2)), 2) + cos(lat1) * cos(lat2) * pow((sin((lon1 - lon2) / 2)), 2)));
                var f = (1 / 50) * fPoints.length;
                f = f.toFixed(6);
                var A = sin((1 - f) * d) / sin(d)
                var B = sin(f * d) / sin(d)
                var x = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2)
                var y = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2)
                var z = A * sin(lat1) + B * sin(lat2)

                var latN = atan2(z, sqrt(pow(x, 2) + pow(y, 2)))
                var lonN = atan2(y, x)
                var p = new google.maps.LatLng(latN / (PI / 180), lonN / (PI / 180));
                marker.setPosition(p);
                fPoints.push(p);

                if (fPoints.length < 50) {
                    window.setTimeout(function () { plotRoute(p1, p2) }, 50);
                }
                else {
                    fPoints.push(p2);
                    marker.setPosition(p2);
                    marker.setMap(null);
                    nextRoute();
                }
            }

        }

        window.onload = loadMap;
    });
</script>
</html>
