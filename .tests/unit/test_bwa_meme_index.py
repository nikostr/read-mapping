import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_bwa_meme_index():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/bwa_meme_index/data")
        expected_path = PurePosixPath(".tests/unit/bwa_meme_index/expected")
        config_path = PurePosixPath(".tests/unit/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("resources/genome.fasta.0123 resources/genome.fasta.amb resources/genome.fasta.ann resources/genome.fasta.pac resources/genome.fasta.pos_packed resources/genome.fasta.suffixarray_uint64 resources/genome.fasta.suffixarray_uint64_L0_PARAMETERS resources/genome.fasta.suffixarray_uint64_L1_PARAMETERS resources/genome.fasta.suffixarray_uint64_L2_PARAMETERS", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "resources/genome.fasta.0123 resources/genome.fasta.amb resources/genome.fasta.ann resources/genome.fasta.pac resources/genome.fasta.pos_packed resources/genome.fasta.suffixarray_uint64 resources/genome.fasta.suffixarray_uint64_L0_PARAMETERS resources/genome.fasta.suffixarray_uint64_L1_PARAMETERS resources/genome.fasta.suffixarray_uint64_L2_PARAMETERS",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
    
            "--directory",
            workdir,
        ])

        # Check the output byte by byte using cmp.
        # To modify this behavior, you can inherit from common.OutputChecker in here
        # and overwrite the method `compare_files(generated_file, expected_file), 
        # also see common.py.
        common.OutputChecker(data_path, expected_path, workdir).check()
