import imagej, os

from concurrent.futures import ProcessPoolExecutor
from functools import partial
from pathlib import Path
from random import shuffle
from tkinter import filedialog, Tk

types_to_look_for = ['.tif', '.oir']

def build_macro(save_path, file_list):
    m = f"""
        names = newArray("{file_list}")
        setBatchMode(true);
        for (i=0; i<names.length; i++) {{
            open(names[i]);
            title = getTitle();
            run("8-bit");
            run("Skeletonize (2D/3D)");
            run("Z Project...", "projection=[Max Intensity]");
            saveAs("tiff", "{save_path}" + title);
            run("Close All");
        }}
    """
    return m








def fast_ij(save_path, names: list):
    files = [f'{f.as_posix()}' for f in names]
    file_list = '", "'.join(files)
    ij = imagej.init('C:\\Users\\User\\Desktop\\Fiji.app')
    print('Starting run.')
    ij.py.run_macro(build_macro(save_path, file_list))
    print('Done.')


if __name__ == '__main__':
    root = Tk()
    root.withdraw()
    incoming = Path(filedialog.askdirectory())
    print(incoming)
    files = [f for f in incoming.iterdir() if f.suffix.lower() in types_to_look_for]
    incoming_n = len(files)
    shuffle(files)

    outgoing = Path(filedialog.askdirectory())
    outgoing_n = len(list(outgoing).iterdir())

    n = len(files) // 16 + 1 # Number of files per chunk
    splitted = [files[i * n:(i + 1) * n] for i in range((len(files) + n - 1) // n )]  
    print(f'Running {len(splitted)} processes.')

    run_this = partial(fast_ij, f'{outgoing.as_posix()}/')
    executor = ProcessPoolExecutor(max_workers=32)
    executor.map(run_this, splitted)
    executor.shutdown(wait=True)

    if outgoing_n + incoming_n != len(list(outgoing.iterdir())):
        print('Number of output file is weird. Recheck if all files are processed.')

    print('All done!')
