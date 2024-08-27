#!/usr/bin/perl -w

# Define os arquivos de entrada e saída correspondentes
@arquivos = (
    {entrada => 'DAT000001.track_mu', saida => 'rezultate_mu'},
    {entrada => 'DAT000001.track_em', saida => 'rezultate_em'},
    {entrada => 'DAT000001.track_hd', saida => 'rezultate_hd'}
);

# Processa cada arquivo
foreach $arquivo (@arquivos) {
    my $datafile = $arquivo->{entrada};
    my $rezultate = $arquivo->{saida};

    # Abre o arquivo de entrada
    open(DATAFILE, $datafile) or die "Não foi possível abrir $datafile: $!";
    binmode(DATAFILE);

    # Abre o arquivo de saída
    open(REZULTATE, ">$rezultate") or die "Não foi possível criar $rezultate: $!";

    sysseek(DATAFILE, 0, 0) or die "Não foi possível buscar byte 0 em $datafile: $!";
    my $tester = 0;

    while (read(DATAFILE, my $buffer2, 48)) {
        my $buffer = substr($buffer2, 4, 40);
        my @propriet = unpack("A4" x 10, $buffer);
        for (my $i = 0; $i < 10; $i++) {
            $propriet[$i] = unpack("f", pack("A*", $propriet[$i]));
        }
        print REZULTATE join(" ", @propriet);
        print REZULTATE "\n";
        $tester++;
    }

    close(REZULTATE);
    close(DATAFILE);
}
