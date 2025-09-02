function theFileName = GetFileName(~)
% FileName = GetFileName(~) User interface for letting the user easily
% specify a file name. A string is returned unless the user selects Cancel,
% in which case an empty string is returned. 21Nov2021
% CRCat and associated software is licensed under the MIT open software
% license. See the file LICENSE.TXT in the main directory.

    [ aFileName,aFileDir ] = uigetfile( '*.*','Select File');
    
    if ~ischar( aFileName ) % uigetfile returns 0 if user hit cancel.
        theFileName = '';
    else
        theFileName = fullfile( aFileDir,aFileName );
    end % if ischar
    
end % GetFileName

