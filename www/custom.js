/* 
Controls the sidebar behavior in the Shiny dashboard.
*/

$(document).ready(function () {
  var $body = $('body');
  var $sidebar = $('.main-sidebar');
  var $toggle = $('.sidebar-toggle');

  $toggle.add($sidebar).on('mouseenter', function () {
    if ($body.hasClass('sidebar-collapse')) {
      $body.removeClass('sidebar-collapse').addClass('sidebar-expanded-on-hover');
    }
  });

  $sidebar.on('mouseleave', function () {
    if ($body.hasClass('sidebar-expanded-on-hover')) {
      $body.removeClass('sidebar-expanded-on-hover').addClass('sidebar-collapse');
    }
  });

  $toggle.on('click', function () {
    $body.toggleClass('sidebar-collapse');
  });
});

/*
Offline genomes for IGV (Epigenome Visualisation > IGV).
igvShiny only knows genomes loaded from igv.org or FASTA-based custom genomes.
For dataMode 'offline' (modules/Epigenome/03_Epigenome_igv_offline_genome.R),
build the igv.js genome from local chromosome sizes, cytobands and gene models
instead (no DNA sequence). Wrapped just before the IGV output is rendered,
because igvShiny.js may be loaded after this file.
*/
function wrapIgvGenomeOptions() {
  if (typeof window.genomeSpecificOptions !== 'function' || window.genomeSpecificOptions.offlineWrapped) {
    return;
  }
  var original = window.genomeSpecificOptions;
  var wrapped = function (genomeName, stockGenome, dataMode, initialLocus, displayMode, trackHeight,
                          fasta, fastaIndex, annotation, moduleNS) {
    if (dataMode !== 'offline') {
      return original.apply(this, arguments);
    }
    var reference = {
      id: genomeName,
      name: genomeName,
      format: 'chromsizes',
      fastaURL: fasta,        // chromosome sizes
      cytobandURL: fastaIndex // cytobands (data URL)
    };
    if (annotation && annotation !== 'NA') {
      reference.tracks = [{
        type: 'annotation',
        format: 'bed',
        name: 'RefSeq genes',
        url: annotation,
        displayMode: 'COLLAPSED',
        searchable: true, // search gene names locally instead of igv.org
        order: Number.MAX_VALUE
      }];
    }
    return {
      locus: initialLocus,
      flanking: 1000,
      showRuler: true,
      minimumBases: 5,
      loadDefaultGenomes: false, // do not fetch the genome list from igv.org
      reference: reference
    };
  };
  wrapped.offlineWrapped = true;
  window.genomeSpecificOptions = wrapped;
}

$(document).on('shiny:value', function () {
  wrapIgvGenomeOptions();
});
