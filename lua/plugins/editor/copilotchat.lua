return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    cmd = {
      "CopilotChat",
      "CopilotChatClose",
      "CopilotChatCommit",
      "CopilotChatExplain",
      "CopilotChatFix",
      "CopilotChatOpen",
      "CopilotChatOptimize",
      "CopilotChatReset",
      "CopilotChatReview",
      "CopilotChatToggle",
    },
    keys = {
      { "<F6>", "<cmd>CopilotChatToggle<CR>", desc = "Toggle Copilot Chat" },
    },
    opts = {
      -- See Configuration section for options
      -- e.g. model = "gpt-4o", window = { ... }, etc.
    },
  },
}
