function applyPrfFile(prfFullpath)
%% Input checking
if ~nargin
   disp('No .prf file provided - aborting...'); return 
end
%% Open and parse the prf file
fid = fopen(prfFullpath,'rt');
C = textscan(fid, '%s%s', 'Delimiter','=', 'CollectOutput',true);
C = C{1};
fclose(fid);
%% Make sure that system defaults are off:
com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem', false);
%% Interate over all settings and apply everything:
for ind1=1:size(C,1)
    prefname = C{ind1,1};
    preftype = C{ind1,2}(1);
    prefval = C{ind1,2}(2:end);
    switch preftype
        case 'B' % boolean
            val = strcmp(prefval,'true');
            com.mathworks.services.Prefs.setBooleanPref(prefname, val);
        case 'C' % RGB color
            val = int32(str2double(prefval));
            com.mathworks.services.Prefs.setRGBColorPref(prefname, val);
            com.mathworks.services.ColorPrefs.notifyColorListeners(prefname);
        case 'I' % int16
            val = int32(str2double(prefval));
            com.mathworks.services.Prefs.setIntegerPref(prefname,val);            
        case 'J' % double / int64
            val = str2double(prefval);
            com.mathworks.services.Prefs.setDoublePref(prefname,val);            
        case 'S' % string
            com.mathworks.services.Prefs.setStringPref(prefname,prefval);            
        case 'F' % font - F0 12 Dialog
            % Building a Java font object from the input:
            val = strsplit(prefval,' ');
            newFont = java.awt.Font(val{3}, str2double(val{1}), str2double(val{2}));
            % Setting-specific handling:
            switch prefname
              % Fonts corresponding to existing cases will be committed and 
              % applied automatically.
              case 'Desktop.Font.Text'
                com.mathworks.services.Prefs.setBooleanPref('GeneralTextUseSystemFont', false);
                com.mathworks.services.FontPrefs.setTextFont(newFont);
              case 'Desktop.Font.Code'
                com.mathworks.services.FontPrefs.setCodeFont(newFont);
              otherwise
                % Commit font setting to matlab.prf:
                com.mathworks.services.Prefs.setFontPref(prefname, newFont);
                disp(['[' 8 '- Notice:]' 8 ' you have changed an unrecognized'...
                  ' font preference (' prefname ') - a restart of MATLAB may'...
                  ' be required for changes to take effect.'])
            end
              
        case 'R' % rect - R0 0 0 0
          %TODO
%       case '?' % StringList
          %TODO
        otherwise
            % Unhandled property - ignored.
    end
end