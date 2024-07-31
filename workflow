# Imports
import struct

def check_file(rezultate_em, rezultate_mu, rezultate_hd):
    """It checks the input files to ensure they are optimized."""
    files = [rezultate_em, rezultate_mu, rezultate_hd]

    for file in files:
        file = open(arquivo, 'r')
        new_file = open(f'ED{file}', 'w')

        for lines in file:
            line = lines.replace('\n', '')
            l = line.split(' ')

            if '' not in l and l[2] != l[6]:
                for object in l:
                    new_file.write(object)
                    new_file.write(' ')
                new_file.write('\n')

        file.close()


def tracks_to_root(DAT_em, DAT_mu, DAT_hd):
    """Convert the original binary file to a new text file."""
    datafiles = [DAT_em, DAT_mu, DAT_hd]
    rezultates = 'rezultate_'

    for datafile in datafiles:
        rezultate_file = resultates + data_file

        with open(data_file, 'rb') as data_file, open(rezultate_file, 'w') as rezult_file:
            flag = 0

            while True:
                buffer2 = data_file.read(48)
                if not buffer2:
                    break

                # Ignoring the first 4 bytes and taking the next 40 bytes.
                buffer = buffer2[4:44]

                propriet = []
                for i in range(0, 40, 4):
                    # Unpacking as float.
                    propriet.append(struct.unpack('f', buffer[i:i+4])[0])

                # Writing to the results file.
                rezult_file.write(" ".join(map(str, propriet)) + "\n")

                flag += 1
