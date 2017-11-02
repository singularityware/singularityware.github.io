---
title: Contributors
sidebar: main_sidebar
permalink: people
folder: docs
toc: false
---

<div id="contributors" style="display:none"></div>

<script src="{{ "assets/js/showdown.min.js" }}"></script>
<script>
$(document).ready(function(){


    url = "https://raw.githubusercontent.com/singularityware/singularity/master/CONTRIBUTORS.md"

    $.get(url, function(data) {

        var converter = new showdown.Converter(),
                 html = converter.makeHtml(data);

        $('#contributors').html(html)
        $('#contributors').show();
    });

});
</script>

