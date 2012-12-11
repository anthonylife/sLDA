function corp = loadreview(trainfile, dicwordnum)
%
%   LOADREVIEW load review text data from inputfile and return complete data structure.
%
%   Input variable:
%       - trainfile: the address of input file
%       - dicwordnum: number of all unique words in dictionary
%
%   Output variable:
%       - corp: formatted reveiw text
%
%   Date: 12/11/2012


% Count number of file lines
docnum = 0;
rfd = fopen(trainfile, 'r');
while ~feof(rfd),
    inline = fgetl(rfd);
    docnum = docnum + 1;
end
fclose(rfd);

% Fill the doc structure
doc = repmat(struct('id', [], 'rate', [], 'word', [], 'docwordnum', []), 1, docnum);
corp = struct('doc', doc, 'docnum', docnum, 'dicwordnum', dicwordnum);

rfd = fopen(trainfile, 'r');
docnum = 0;
while ~feof(rfd),
    inline = fgetl(rfd);
    docnum = docnum + 1;
    parts = strread(inline, '%s', 'delimiter', ' ');
    corp.doc(docnum).id = str2num(parts(1));
    corp.doc(docnum).rate = str2num(parts(2));
    uniqwordnum = length(parts) - 2;
    
    wordnum = 0;    % total number of words in each document, including repeated words
    for i=1:uniqwordnum,
        [tempid, tempnum]= strread(parts(i+2), '%d', 'delimiter', ':');
        wordnum = wordnum + tempnum;
    end
   
    corp.doc(docnum).docwordnum = wordnum;
    corp.doc(docnum).word = repmat(0, 1, wordnum);
    
    wordnum = 0;
    for i=1:uniqwordnum,
        [wordid, repeatednum] = strread(parts(i+2), '%d', 'delimiter', ':');
        for j=1:repeatednum,    % note repeated words
            wordnum = wordnum + 1;
            corp.doc(docnum).word(wordnum) = wordid;
        end
    end
end
fclose(rfd);
