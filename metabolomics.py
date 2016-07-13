"""
Metabolomics Datatypes
"""

# this file should be placed in lib/galaxy/datatypes

import binascii
import logging
import re

from galaxy.datatypes import data
from galaxy.datatypes.binary import Binary
from galaxy.datatypes.data import Text
from galaxy.datatypes.tabular import Tabular
from galaxy.datatypes.xml import GenericXml
from galaxy.util import nice_size

log = logging.getLogger(__name__)

class MzML(MetabolomicsXml):
    """mzML data"""
    file_ext = "mzml"
    edam_format = "format_3244"
    blurb = 'mzML Mass Spectrometry data'
    root = "(mzML|indexedmzML)"

class MzXML(MetabolomicsXml):
    """mzXML data"""
    file_ext = "mzxml"
    blurb = "mzXML Mass Spectrometry data"
    root = "mzXML"

class BrukerMS1RAW(Binary):
    """Class describing a Bruker MS1 binary RAW file"""
    # FIXME: more like folder extension???
    file_ext = "d"
    allow_datatype_change = True
    composite_type = 'auto_primary_file'

    def __init__(self, **kwd):
        Binary.__init__(self, **kwd)

        self.add_composite_file(
            'analysis.baf',
            description='analysis.baf file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'analysis.baf_idx',
            description='analysis.baf file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'analysis.baf_xtr',
            description='analysis.baf file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'analysis.content',
            description='analysis.content file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'analysis.0.DataAnalysis.method',
            description='analysis.0.DataAnalysis.method file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'analysis.0.result_c',
            description='analysis.0.result_c file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'calib.bin',
            description='calib.bin file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'desktop.ini',
            description='desktop.ini file that contains some metadata.',
            optional='True',
            is_binary=False)

        self.add_composite_file(
            'ms-waters-pda.hss',
            description='ms-waters-pda.hss file.',
            optional='False',
            is_binary=False)

        self.add_composite_file(
            '*.hdx',
            description='any .hdx file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.u2',
            description='any .u2 file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.und',
            description='any .und file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.m',
            description='any .m folder.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.m/DataAnalysis.Method',
            description='DataAnalysis.Method file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.m/desktop.ini',
            description='*.m/desktop.ini file.',
            optional='True',
            is_binary=False)

        self.add_composite_file(
            '*.m/hystar.method',
            description='*.m/hystar.method file.',
            optional='True',
            is_binary=True)

        self.add_composite_file(
            '*.m/microTOFQAcquisition.method',
            description='*.m/microTOFQAcquisition.method file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.m/submethods.xml',
            description='*.m/submethods.xml file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.mcf',
            description='any .mcf file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            '*.mcf_idx',
            description='any .mcf_idx file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'Storage.mcf_idx',
            description='Storage.mcf_idx file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'SampleInfo.xml',
            description='SampleInfo.xml file that contains some metadata.',
            optional='False',
            is_binary=False)

        self.add_composite_file(
            'NuGenesisTemplate.txt',
            description='NuGenesisTemplate.txt file.',
            optional='True',
            is_binary=False)

        self.add_composite_file(
            'LCParms.txt',
            description='LCParms.txt file.',
            optional='False',
            is_binary=False)

        self.add_composite_file(
            'HS_columns.xmc',
            description='HS_columns.xmc file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'BackgroundLineNeg.ami',
            description='BackgroundLineNeg.ami file.',
            optional='True',
            is_binary=True)

        self.add_composite_file(
            'BackgroundUV.ami',
            description='BackgroundUV.ami file.',
            optional='True',
            is_binary=True)

        self.add_composite_file(
            'Calibrator.ami',
            description='Calibrator.ami file.',
            optional='False',
            is_binary=True)

        self.add_composite_file(
            'DensViewNeg.ami',
            description='DensViewNeg.ami file.',
            optional='True',
            is_binary=True)

        self.add_composite_file(
            'DensViewNegBgnd.ami',
            description='DensViewNegBgnd.ami file.',
            optional='True',
            is_binary=True)

    def generate_primary_file(self, dataset=None):
        rval = ['<html><head><title>Bruker MS1 RAW Composite Dataset</title></head><p/>']
        rval.append('<div>This composite dataset is composed of the following files:<p/><ul>')
        for composite_name, composite_file in self.get_composite_files(dataset=dataset).iteritems():
            fn = composite_name
            opt_text = ''
            if composite_file.optional:
                opt_text = ' (optional)'
            if composite_file.get('description'):
                rval.append('<li><a href="%s" type="text/plain">%s (%s)</a>%s</li>' % (fn, fn, composite_file.get('description'), opt_text))
            else:
                rval.append('<li><a href="%s" type="text/plain">%s</a>%s</li>' % (fn, fn, opt_text))
        rval.append('</ul></div></html>')
        return "\n".join(rval)

    def set_peek(self, dataset, is_multi_byte=False):
        if not dataset.dataset.purged:
            dataset.peek = "Bruker MS1 RAW file"
            dataset.blurb = nice_size(dataset.get_size())
        else:
            dataset.peek = 'file does not exist'
            dataset.blurb = 'file purged from disk'

    def display_peek(self, dataset):
        try:
            return dataset.peek
        except:
            return "Bruker MS1 RAW file (%s)" % (nice_size(dataset.get_size()))

Binary.register_sniffable_binary_format("bruker.d", "d", BrukerMS1RAW )

class nmrML(MetabolomicsXml):
    """nmrML data"""
    file_ext = "nmrml"
    blurb = 'nmrML NMR data'
    root = "nmrML"
