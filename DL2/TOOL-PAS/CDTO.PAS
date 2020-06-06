uses dos;
begin
	if paramcount <> 1 then
	begin
		writeln('cdto D:\DIRECTORY');
		writeln('Changes drive AND directory with a single command.');
		writeln('Public domain by Samuel H. Smith, 9/11/92');
                halt(1);
	end;

	chdir(paramstr(1));
end.
