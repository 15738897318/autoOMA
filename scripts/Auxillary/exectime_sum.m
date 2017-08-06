function result = exectime_sum(filename)

[etime, procid, ~] = xlsread(filename);

result.signal1 = etime(find(strcmp(procid,'sa12')));
result.psd = etime(find(strcmp(procid,'psd')));
result.psdpeak = etime(find(strcmp(procid,'pp')));
result.psdpayload = etime(find(strcmp(procid,'ppc')));
result.command1 = etime(find(strcmp(procid,'cp')));

result.signal2 = etime(find(strcmp(procid,'sa22')));
result.fftcalc2 = etime(find(strcmp(procid,'fft2')));
result.fftsel2 = etime(find(strcmp(procid,'fftsel2')));
result.fftpayload2 = etime(find(strcmp(procid,'fp2')));
result.command2 = etime(find(strcmp(procid,'cp2')));

result.signal3 = etime(find(strcmp(procid,'sa23')));
result.fftcalc3 = etime(find(strcmp(procid,'fft3')));
result.fftsel3 = etime(find(strcmp(procid,'fftsel3')));
result.fftpayload3 = etime(find(strcmp(procid,'fp3')));
result.command3 = etime(find(strcmp(procid,'cp3')));

result.phase1.signal = [mean(result.signal1), std(result.signal1)];
result.phase1.psd = [mean(result.psd), std(result.psd)];
result.phase1.psdpeak = [mean(result.psdpeak), std(result.psdpeak)];
result.phase1.psdpayload = [mean(result.psdpayload), std(result.psdpayload)];
result.phase1.command = [mean(result.command1), std(result.command1)];

result.phase2.signal = [mean(result.signal2), std(result.signal2)];
result.phase2.fftcalc = [mean(result.fftcalc2), std(result.fftcalc2)];
result.phase2.fftsel = [mean(result.fftsel2), std(result.fftsel2)];
result.phase2.fftpayload = [mean(result.fftpayload2), std(result.fftpayload2)];
result.phase2.command = [mean(result.command2), std(result.command2)];

result.phase3.signal = [mean(result.signal3), std(result.signal3)];
result.phase3.fftcalc = [mean(result.fftcalc3), std(result.fftcalc3)];
result.phase3.fftsel = [mean(result.fftsel3), std(result.fftsel3)];
result.phase3.fftpayload = [mean(result.fftpayload3), std(result.fftpayload3)];
result.phase3.command = [mean(result.command3), std(result.command3)];

csvdata = vertcat(result.phase1.signal,result.phase1.psd,result.phase1.psdpeak,result.phase1.psdpayload,result.phase1.command);
csvdata = vertcat(csvdata, result.phase2.signal, result.phase2.fftcalc, result.phase2.fftsel, result.phase2.fftpayload, result.phase2.command);
csvdata = vertcat(csvdata, result.phase3.signal, result.phase3.fftcalc, result.phase3.fftsel, result.phase3.fftpayload, result.phase3.command);

csvwrite('exectime.csv',csvdata);