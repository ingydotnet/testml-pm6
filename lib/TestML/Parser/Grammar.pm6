module TestML::Parser::Grammar;
use v6;

sub grammar {
    return {
  'assertion_operation' => [
    '/$ws+/',
    'assertion_operator',
    '/$ws+/',
    'test_expression'
  ],
  'point_lines' => '/((?:(?!$block_marker|$point_marker)$line)*)/',
  'assertion_call_start' => [
    '/$call_indicator$assertion_name\\($ws*/'
  ],
  'point_marker' => '/---/',
  'ANY' => '[\\s\\S]',
  'block_header' => [
    'block_marker',
    {
      '^' => '?',
      '=' => [
        '/$SPACE+/',
        'block_label'
      ]
    },
    '/$SPACE*$EOL/'
  ],
  'HASH' => '#',
  'test_expression' => [
    'sub_expression',
    {
      '/' => [
        [
          '!assertion_call_start',
          'call_indicator',
          'sub_expression'
        ]
      ],
      '^' => '*'
    }
  ],
  'line' => '/$NON_BREAK*$EOL/',
  'sub_expression' => [
    {
      '/' => [
        'transform_call',
        'data_point',
        'quoted_string',
        'constant'
      ]
    }
  ],
  'ESCAPE' => '[0nt]',
  'LOWER' => '[a-z]',
  'ALPHANUM' => '[A-Za-z0-9]',
  'SINGLE' => '\'',
  'block_marker' => '/===/',
  'core_meta_keyword' => '/(?:Title|Data|Plan|BlockMarker|PointMarker)/',
  'user_transform' => '/($LOWER$WORD*)/',
  'DIGIT' => '[0-9]',
  'BACK' => '\\',
  'assertion_operator' => '/(==)/',
  'test_section' => [
    {
      '/' => [
        'ws',
        'test_statement'
      ],
      '^' => '*'
    }
  ],
  'transform_name' => {
    '/' => [
      'user_transform',
      'core_transform'
    ]
  },
  'data_point' => '/($STAR$LOWER$WORD*)/',
  'DOLLAR' => '\\$',
  'data_section' => '/($block_marker(?:$SPACE|$EOL)$ANY+|\\Z)/',
  'single_quoted_string' => '/(?:$SINGLE(([^$BREAK$BACK$SINGLE]|$BACK$SINGLE|$BACK$BACK)*?)$SINGLE)/',
  'argument' => [
    'sub_expression'
  ],
  'call_indicator' => '/(?:$DOT$ws*|$ws*$DOT)/',
  'EOL' => '\\r?\\n',
  'DOUBLE' => '"',
  'assertion_call' => [
    'assertion_call_start',
    'test_expression',
    '/$ws*\\)/'
  ],
  'constant' => '/($UPPER$WORD*)/',
  'meta_testml_statement' => '/%TestML:$SPACE+($testml_version)(?:$SPACE+$comment|$EOL)/',
  'UPPER' => '[A-Z]',
  'WORD' => '\\w',
  'BREAK' => '\\n',
  'document' => [
    'meta_section',
    'test_section',
    {
      '/' => [
        'data_section'
      ],
      '^' => '?'
    }
  ],
  'SPACES' => '\\ \\t',
  'meta_keyword' => '/(?:$core_meta_keyword|$user_meta_keyword)/',
  'point_phrase' => '/($NON_BREAK*)/',
  'DOT' => '\\.',
  'unquoted_string' => '/[^$SPACES$BREAK$HASH](?:[^$BREAK$HASH]*[^$SPACES$BREAK$HASH])?/',
  'data' => {
    '^' => '*',
    '=' => 'data_block'
  },
  'meta_section' => [
    '/(?:$comment|$blank_line)*/',
    {
      '/' => [
        'meta_testml_statement',
        {
          '_' => 'No TestML meta directive found'
        }
      ]
    },
    {
      '/' => [
        'meta_statement',
        'comment',
        'blank_line'
      ],
      '^' => '*'
    }
  ],
  'lines_point' => [
    '/$point_marker$SPACE+/',
    'user_point_name',
    '/$SPACE*$EOL/',
    'point_lines'
  ],
  'data_block' => [
    'block_header',
    {
      '/' => [
        'blank_line',
        'comment'
      ],
      '^' => '*'
    },
    {
      '^' => '*',
      '=' => 'block_point'
    }
  ],
  'test_statement' => [
    'test_expression',
    {
      '^' => '?',
      '=' => 'assertion_expression'
    },
    {
      '/' => [
        '/;/',
        {
          '_' => 'You seem to be missing a semicolon'
        }
      ]
    }
  ],
  'STAR' => '\\*',
  'SPACE' => '[\\ \\t]',
  'ws' => '/(?:$SPACE|$EOL|$comment)/',
  'blank_line' => '/$SPACE*$EOL/',
  'block_label' => [
    '/([^$SPACES$BREAK]($NON_BREAK*[^SPACES$BREAK])?)/'
  ],
  'assertion_name' => '/EQ/',
  'phrase_point' => [
    '/$point_marker$SPACE+/',
    'user_point_name',
    '/:$SPACE/',
    'point_phrase',
    '/$EOL/',
    '/(?:$comment|$blank_line)*/'
  ],
  'user_meta_keyword' => '/$LOWER$WORD*/',
  'NON_BREAK' => '.',
  'core_transform' => '/($UPPER$WORD*)/',
  'transform_call' => [
    'transform_name',
    '/\\($ws*/',
    'argument_list',
    '/$ws*\\)/'
  ],
  'meta_value' => '/(?:$single_quoted_string|$double_quoted_string|$unquoted_string)/',
  'testml_version' => '/($DIGIT$DOT$DIGIT+)/',
  'quoted_string' => {
    '/' => [
      'single_quoted_string',
      'double_quoted_string'
    ]
  },
  'assertion_expression' => {
    '/' => [
      'assertion_operation',
      'assertion_call'
    ]
  },
  'argument_list' => {
    '^' => '?',
    '=' => [
      'argument',
      {
        '^' => '*',
        '=' => [
          '/$ws*,$ws*/',
          'argument'
        ]
      }
    ]
  },
  'comment' => '/$HASH$line/',
  'block_point' => {
    '/' => [
      'lines_point',
      'phrase_point'
    ]
  },
  'double_quoted_string' => '/(?:$DOUBLE(([^$BREAK$BACK$DOUBLE]|$BACK$DOUBLE|$BACK$BACK|$BACK$ESCAPE)*?)$DOUBLE)/',
  'meta_statement' => '/%($meta_keyword):$SPACE+($meta_value)(?:$SPACE+$comment|$EOL)/',
  'user_point_name' => '/($LOWER$WORD*)/'
};
}
