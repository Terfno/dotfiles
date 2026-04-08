{
  '$schema': 'https://opencode.ai/config.json',
  default_agent: 'plan',
  provider: {
    ollama: {
      npm: '@ai-sdk/openai-compatible',
      name: 'Ollama(local)',
      options: {
        baseURL: 'http://127.0.0.1:11434/v1',
      },
      models: {
        'gpt-oss:20b': {
          name: 'gpt-oss:20b',
          tool_call: true,
          reasoning: true,
        },
      },
    },
  },
}
