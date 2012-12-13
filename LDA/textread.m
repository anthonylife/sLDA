%TEXTREAD read text from corpus word dictionary.

function dict = textread()
global Corp;

word = struct('word', []);
dict = repmat(word, Corp.nw, 1);

idx = 1;
rfd = fopen(Corp.dictfile);
while ~feof(rfd),
    dict(idx).word = fgetl(rfd);
    idx = idx + 1;
end
fclose(rfd);
