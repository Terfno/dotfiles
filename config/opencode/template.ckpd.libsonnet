// for cookpad
// fill aws resource arn for each model id, and rename this to ckpd.libsonnet.
// then run render-config.sh to generate config.json with bedrock providers for cookpad.

{
  provider: {
    'amazon-bedrock': {
      options: {
        region: 'us-east-1',
        profile: 'claude-code',
      },
      models: {
        'ckpd-sonnet': {
          id: 'arn:aws:bedrock:...',
        },
        'ckpd-opus': {
          id: 'arn:aws:bedrock:...',
        },
        'ckpd-haiku': {
          id: 'arn:aws:bedrock:...',
        },
      },
    },
  },
}
