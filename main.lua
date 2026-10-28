-- fzf-marks plugin for yazi
-- Reads $FZF_MARKS_FILE (default ~/.fzf-marks) and jumps to selected directory via fzf

return {
	entry = function()
		local function log(msg) ya.dbg("fzf-marks: " .. msg) end

		log("entry called")

		-- Same variable and default as https://github.com/urbainvaes/fzf-marks
		local marks_file = os.getenv("FZF_MARKS_FILE")
		if not marks_file or marks_file == "" then
			marks_file = os.getenv("HOME") .. "/.fzf-marks"
		end
		marks_file = marks_file:gsub("^~", os.getenv("HOME"))
		log("marks_file=" .. marks_file)

		local f = io.open(marks_file, "r")
		if not f then
			ya.notify({ title = "fzf-marks", content = "Marks file not found: " .. marks_file, level = "error", timeout = 5 })
			return
		end
		f:close()

		-- Suspend yazi's UI so fzf can take over the terminal
		local permit = ui.hide()
		log("ui.hide called")

		local child, err = Command("sh")
			:arg({
				"-c",
				"cut -f 3 -d ' ' \"$1\" | fzf",
				"sh",
				marks_file,
			})
			:stdin(Command.INHERIT)
			:stdout(Command.PIPED)
			:stderr(Command.INHERIT)
			:spawn()

		if not child then
			permit:drop()
			log("spawn failed: " .. tostring(err))
			ya.notify({ title = "fzf-marks", content = "Failed to spawn: " .. tostring(err), level = "error" })
			return
		end

		log("spawned, waiting...")
		local output, _ = child:wait_with_output()
		permit:drop()
		log("permit dropped, exit_code=" .. (output and tostring(output.status.code) or "nil"))

		if not output or output.status.code ~= 0 then
			return
		end

		log("stdout=[" .. output.stdout .. "]")
		local dir = output.stdout:gsub("%s+$", "")
		log("dir=[" .. dir .. "]")

		if dir == "" then
			log("dir empty, aborting")
			return
		end

		dir = dir:gsub("^~", os.getenv("HOME"))
		log("cd -> " .. dir)
		ya.emit("cd", { dir })
	end,
}
