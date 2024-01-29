function checkDir(dir2check)

cdbackdir = pwd;
cd2exist(dir2check);
cd(cdbackdir)

end

function outdir = cd2exist(tmpdir)
outdir = tmpdir;
if ~exist(tmpdir),
    subdirIdx = strfind(tmpdir,'\');
    outdir = tmpdir(1:subdirIdx(end));
else
    cd(tmpdir);
end
end