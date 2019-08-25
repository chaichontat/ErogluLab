import multiprocessing as mp
import time

from itertools import cycle
from pathlib import Path
from tkinter import filedialog, Tk

import imagej
import psutil
from colorama import Fore

ij_path = "C:\\Users\\Chaichontat\\Desktop\\Fiji.app"


class ParallelIJ:
    """
    Class to execute ImageJ macro in parallel.
    Automatic dispatch of files across ImageJ instances.

    Takes in paths of input/output directories.
    Macro is expected to be one that runs on an opened image (NOT batch).

    """
    TYPES = ['.tif', '.tiff']

    def __init__(self, *, in_path, out_path, macro_path, out_prefix, out_suffix, ij_path=None):
        self.in_path = Path(in_path)
        self.out_path = Path(out_path)
        self.macro = Path(macro_path).read_text()
        self.check_macro()
        self.ij_path = Path(ij_path)
        self.out_prefix = out_prefix
        self.out_suffix = out_suffix

        self.files = [f for f in incoming.iterdir() if f.suffix.lower() in ParallelIJ.TYPES]
        m = mp.Manager()
        self.q_in = m.Queue()
        self.q_out = m.Queue()

        [self.q_in.put(f) for f in self.files]

    def check_args(self):
        if len(self.files) == 0:
            raise FileNotFoundError(f'No file in the selected directory that ends with {ParallelIJ.TYPES}.')

    def check_macro(self):
        """
        Check if macro contains line that starts with {checks}.
        Designed to prevent inadvertent run of batch macro.
        """
        lines = self.macro.split('\n')
        checks = ['run("Bio-Formats Importer"', 'open', 'saveAs']
        for check in checks:
            if any([line.startswith(check) for line in lines]):
                print(Fore.RED + f'Macro contains {check} command. Make sure that the macro is prepared properly.' + Fore.RESET)

    def build_macro(self, file: Path):
        """
        Encapsulates macro code with open and save clauses.

        :param file: Path object of file to be run.
        :return: ImageJ macro code with open and save clauses.
        """
        out_name = f'{self.out_prefix}{file.stem}{self.out_suffix}.tif'
        start = f'setBatchMode(true);\n' \
                f'open("{file.as_posix()}");\n'
        end = f'\nsaveAs("tiff", "{self.out_path.as_posix()}/{out_name}");\n' \
              f'run("Close All");\n'

        return f'{start}{self.macro}{end}'

    def ij_instance(self, q_in: mp.Queue, q_out: mp.Queue):
        """
        Function to be spawned in parallel with separate processes.
        Initializes ImageJ and feed in macro code with file names from multiprocessing.Queue.

        :param q_in: Input file names
        :param q_out: Mainly to track progress
        """
        # Use latest Fiji as default.
        ij = imagej.init('sc.fiji:fiji') if self.ij_path is None else imagej.init(self.ij_path.as_posix())
        q_out.put('ready')
        while q_in.qsize() > 0:
            file = q_in.get()
            ij.py.run_macro(self.build_macro(file))
            q_out.put(file)

    def start(self):
        """ Starts the processing pool. """
        proc_num = psutil.cpu_count(logical=False)
        pool = mp.Pool()
        [pool.apply_async(func=self.ij_instance, args=(self.q_in, self.q_out,)) for _ in range(proc_num)]
        pool.close()


def dialogs(*, type_, title):
    assert type_ in ['file', 'folder']
    temp = Path(filedialog.askopenfilename(title=title)) if type_ == 'file' else Path(filedialog.askdirectory(title=title))
    if temp == Path():
        raise Exception
    return temp


if __name__ == '__main__':
    """ User interface """
    root = Tk()
    root.withdraw()
    macro_path = dialogs(type_='file', title="Choose the macro file")
    incoming = dialogs(type_='folder', title="Choose input directory")
    outgoing = dialogs(type_='folder', title="Choose output directory")

    print(f'Input: {incoming}')
    print(f'Output: {outgoing}\n')

    out_prefix = input('Add the following to the BEGINNING of output file name: ')
    out_suffix = input('Add the following to the END of output file name: ')
    if out_suffix == '' and out_prefix == '':
        print(Fore.RED + f'Warning: No prefix and suffix. Outputs may overwrite existing image.' + Fore.RESET)

    parallel = ParallelIJ(in_path=incoming, out_path=outgoing, macro_path=macro_path, ij_path=ij_path,
                          out_prefix=out_prefix,  out_suffix=out_suffix)

    incoming_n = len(parallel.files)
    outgoing_n = len(list(outgoing.iterdir()))

    print(f'\nRun {incoming_n} files with extensions {ParallelIJ.TYPES}')
    print(f'Output file name will be [{out_prefix}FILE_NAME{out_suffix}.tif]')

    proceed = input('Proceed? If yes, type y: ')
    print()
    if proceed.lower() not in ['y', 'yes', 'affirmative', 'sure', 'yeah', 'absolutely', 'indeed', 'agreed', 'ok', 'ay']:
        raise KeyboardInterrupt('Aborted.')

    parallel.start()
    t_start = time.time()

    print('Initializing ImageJ ...')
    for i in range(psutil.cpu_count(logical=False)):
        parallel.q_out.get()

    cursor = (c for c in cycle('|/-\\'))
    while parallel.q_out.qsize() < incoming_n:
        time.sleep(0.25)
        t_elapsed = time.time() - t_start
        print(f'\r{next(cursor)} {parallel.q_out.qsize()}/{incoming_n} files. '
              f'Elapsed time: {time.strftime("%H:%M:%S", time.gmtime(t_elapsed))}', flush=True, end='')

    print('\nAll done!')
