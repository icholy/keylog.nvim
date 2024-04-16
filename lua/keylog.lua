local RingBuffer = {}
RingBuffer.__index = RingBuffer

function RingBuffer.new(cap)
    local buffer = {}
    setmetatable(buffer, RingBuffer)
    buffer.cap = cap
    buffer.data = {}
    buffer.head = 1
    buffer.tail = 1
    buffer.count = 0
    return buffer
end

function RingBuffer:push(item)
    self.data[self.head] = item
    self.head = (self.head % self.cap) + 1
    if self.count == self.cap then
        self.tail = (self.tail % self.cap) + 1
    else
        self.count = self.count + 1
    end
end

function RingBuffer:size()
    return self.count
end

function RingBuffer:values()
    local index = self.tail
    local count = 0
    return function()
        if count < self.count then
            local item = self.data[index]
            index = (index % self.cap) + 1
            count = count + 1
            return item
        end
    end
end

local events = {
	"BufAdd",
	"BufDelete",
	"BufEnter",
	"BufFilePost",
	"BufFilePre",
	"BufHidden",
	"BufLeave",
	"BufModifiedSet",
	"BufNew",
	"BufNewFile",
	"BufRead",
	"BufReadPre",
	"BufUnload",
	"BufWinEnter",
	"BufWinLeave",
	"BufWipeout",
	"BufWrite",
	"BufWriteCmd",
	"BufWritePost",
	"ChanInfo",
	"ChanOpen",
	"CmdUndefined",
	"CmdlineChanged",
	"CmdlineEnter",
	"CmdlineLeave",
	"CmdwinEnter",
	"CmdwinLeave",
	"ColorScheme",
	"ColorSchemePre",
	"CompleteChanged",
	"CompleteDonePre",
	"CompleteDone",
	"CursorHold",
	"CursorHoldI",
	"CursorMoved",
	"CursorMovedI",
	"DiffUpdated",
	"DirChanged",
	"DirChangedPre",
	"ExitPre",
	"FileAppendCmd",
	"FileAppendPost",
	"FileAppendPre",
	"FileChangedRO",
	"FileChangedShell",
	"FileChangedShell",
	"FileReadCmd",
	"FileReadPost",
	"FileReadPre",
	"FileType",
	"FileWriteCmd",
	"FileWritePost",
	"FileWritePre",
	"FocusGained",
	"FocusLost",
	"FuncUndefined",
	"UIEnter",
	"UILeave",
	"InsertChange",
	"InsertCharPre",
	"InsertEnter",
	"InsertLeavePre",
	"InsertLeave",
	"MenuPopup",
	"ModeChanged",
	"QuickFixCmdPre",
	"QuickFixCmdPost",
	"QuitPre",
	"RemoteReply",
	"SearchWrapped",
	"RecordingEnter",
	"RecordingLeave",
	"SessionLoadPost",
	"SessionWritePost",
	"ShellCmdPost",
	"Signal",
	"ShellFilterPost",
	"SourcePre",
	"SourcePost",
	"SourceCmd",
	"SpellFileMissing",
	"StdinReadPost",
	"StdinReadPre",
	"SwapExists",
	"Syntax",
	"TabEnter",
	"TabLeave",
	"TabNew",
	"TabNewEntered",
	"TabClosed",
	"TextYankPost",
	"VimEnter",
	"VimLeave",
	"VimLeavePre",
	"VimResized",
	"VimResume",
	"VimSuspend",
	"WinClosed",
	"WinEnter",
	"WinLeave",
	"WinNew",
	"WinScrolled",
	"WinResized",
}

local M = {}

local keylog = RingBuffer.new(100);

function M.setup()
    local ns = vim.api.nvim_create_namespace('keylog')

    vim.on_key(function (key, typed)
        keylog:push({
            time = os.date("%c"),
            event = "OnKey",
            data = key,
            typed = typed,
        })
    end, keylog_ns)

    vim.api.nvim_create_user_command('KeyLog',function()
        for e in keylog:values() do
            vim.print(e.time .. " " .. e.event .. ": " .. vim.inspect(e.data))
        end
    end, {})

    vim.api.nvim_create_autocmd(events, {
        group = group,
        callback = function (ev)
            keylog:push({
                time = os.date("%c"),
                event = ev.event,
                data = ev.file
            })
        end
    })
end

function M.log()
    return keylog.values()
end

return M