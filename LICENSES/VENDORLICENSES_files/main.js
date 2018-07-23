// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function() {
    $('a.page-scroll').bind('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 1500, 'easeInOutExpo');
        event.preventDefault();
    });
});

// Closes the Responsive Menu on Menu Item Click
$('.navbar-collapse ul li a').click(function() {
  if ($(this).attr('class') != 'dropdown-toggle active' && $(this).attr('class') != 'dropdown-toggle') {
    $('.navbar-toggle:visible').click();
  }
});

// Toggles hidden divs on button click
$('.content-section button').click(function() {
    if (!($(this).hasClass('btn-selected')) && $(this).attr('id') != 'download-btn') {
        $('.content-section button').removeClass('btn-selected');
        $(this).addClass('btn-selected');

        var oldHidden = $('.hidden');
        var oldShown = $('.shown');
        switch($(this).attr('id')) {
            case 'prot-btn':
                $('#prot-content').removeClass('hidden');
                $('#prot-content').addClass('shown');
                break;
            case 'bumb-btn':
                $('#bumb-content').removeClass('hidden');
                $('#bumb-content').addClass('shown');
                break;
            case 'sky-btn':
                $('#sky-content').removeClass('hidden');
                $('#sky-content').addClass('shown');
                break;
            default:
                oldHidden.removeClass('hidden');
                oldHidden.addClass('shown');
                break;
        }
        oldShown.removeClass('shown');
        oldShown.addClass('hidden');
    }
})

// Popup window for license agreements
function popup(link, windowName) {
    if (!window.focus) 
        return true;
    var href;
    if (typeof(link) == 'string') 
        href = link;
    else 
        href = link.href; 
    window.open(href, windowName, 'width=600,height=400,scrollbars=yes'); 
    return false; 
}

// Toggles currently shown license agreement
function switchLicense(className) {
    if ($('div.' + className).hasClass('hidden')) {
        var oldHidden = $('div.' + className);
        var oldShown = $('.shown');
        oldHidden.removeClass('hidden');
        oldHidden.addClass('shown');
        oldShown.removeClass('shown');
        oldShown.addClass('hidden');
    }
}

// Software selector
$('#softwareType').change(function() {
    if ($(this).data('options') == undefined) 
        $(this).data('options', $('#downloadType option').clone());
    var id = $(this).val();
    var options = $(this).data('options').filter('[value=' + id + ']');
    $('#downloadType').html(options);
});
$('#softwareType').change();

// Downloads specified software 
function download() {
    /*var name = document.getElementById('inputName').value;
    if (!validateName(name)) {
        alert("The name field cannot be left blank.");
        return
    }*/

    var email = document.getElementById('inputEmail').value.trim();
    if (email && !validateEmail(email)) {
        alert("Invalid email address.");
        return;
    }

    if (!document.getElementById('license-agreements').checked) {
        alert("You must accept the license agreements before downloading.");
        return;
    }

    var selected = document.getElementById('downloadType');
    var selectedData = selected.options[selected.selectedIndex];
    var downloadType = selectedData.getAttribute('data-value');
    var downloadTypeString = downloadType;
    var matchPattern = /(\/guestAuth\/[\w\/\-.:]+\/content\/[\w\/\-.:]+.tar.bz2)/g;

    if (downloadType.match(/_installer$/)) {
        matchPattern = /(\/guestAuth\/[\w\/\-.:]+\/content\/[\w\/\-.:]+.msi)/g;
        downloadTypeString = downloadTypeString.replace("_installer", "").trim();
    } else if (downloadType.match(/_no_binary_msdata$/)) {
        matchPattern = /(\/guestAuth\/[\w\/\-.:]+\/content\/pwiz-src-without-v-[\w\/\-.:]+.tar.bz2)/g;
        downloadTypeString = downloadTypeString.replace("_no_binary_msdata", "").trim();
    } else if (downloadType.match(/_without_tests$/)) {
        matchPattern = /(\/guestAuth\/[\w\/\-.:]+\/content\/bumbershoot-src-without-t-[\w\/\-.:]+.tar.bz2)/g;
        downloadTypeString = downloadTypeString.replace("_without_tests", "").trim();
    }

    var remoteURL = "http://teamcity.labkey.org/guestAuth/app/rest/builds/status:SUCCESS,buildType:id:" + downloadTypeString + "/artifacts/children";
    //alert("Remote URL: " + remoteURL);

    var teamCityInfoString = "";
    var request = createCORSRequest("GET", remoteURL);
    if (request) {
        request.onload = function(){
            teamCityInfoString = request.responseText;

            var matches = teamCityInfoString.match(matchPattern);
            var downloadURL = matches[0];
            if(email) {
                writeEmailToFile(email, function() {
                    window.location = "http://teamcity.labkey.org" + downloadURL;
                });
            } else {
                window.location = "http://teamcity.labkey.org" + downloadURL;
            }
        };
        request.send();
    }
}

// Writes email to file
function writeEmailToFile(email, callback) {

    $.post("js/ajax.php", {
        email: email
    }, function(data, status) {
        console.log(status);
        callback();
    });
}

// Validates name of downloader
function validateName(name) {
    var nameRegex = /^[A-Za-z\s]+$/;
    return nameRegex.test(name);
}

// Validates email of downloader
function validateEmail(email) {
    var emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return emailRegex.test(email);
}

// Cross-domain AJAX request 
// http://jquery-howto.blogspot.fr/2013/09/jquery-cross-domain-ajax-request.html#cors 
function createCORSRequest(method, url) {
    var xhr = new XMLHttpRequest();
    if ("withCredentials" in xhr){
        // XHR has 'withCredentials' property only if it supports CORS
        xhr.open(method, url, false);
    } else if (typeof XDomainRequest != "undefined"){ // if IE use XDR
        xhr = new XDomainRequest();
        xhr.open(method, url);
    } else {
        xhr = null;
    }
    return xhr;
}

// Javascript equivalent basename function in PHP 
// http://stackoverflow.com/questions/3820381/need-a-basename-function-in-javascript 
function baseName(str) {
   var base = new String(str).substring(str.lastIndexOf('/') + 1); 
    if(base.lastIndexOf(".") != -1)       
        base = base.substring(0, base.lastIndexOf("."));
   return base;
}