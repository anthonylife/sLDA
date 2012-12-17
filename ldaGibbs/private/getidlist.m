function getidlsit()

global Corp;

N = size(Corp.triple, 1);
wordnumlist = sum(Corp.X, 2);
for i=1:size(Corp.X, 1),
    Corp.doc(i).wordid= repmat(0, 1, wordnumlist(i));
end

old_doc_id = 0;
start_idx = 1;
for i=1:N,
    if Corp.triple(i,1) ~= old_doc_id;
        start_idx = 1;
        old_doc_id = Corp.triple(i,1);
    end

    for j=1:Corp.triple(i,3),
        Corp.doc(Corp.triple(i,1)).wordid(start_idx) = Corp.triple(i,2);
        start_idx = start_idx + 1;
    end
end
