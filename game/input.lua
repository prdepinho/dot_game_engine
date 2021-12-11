
local Input = {}

-- keyboard keys from SFML
Input.Unknown = -1 --< Unhandled key
Input.A = 0        --< The A key
Input.B = 1            --< The B key
Input.C = 2            --< The C key
Input.D = 3            --< The D key
Input.E = 4            --< The E key
Input.F = 5            --< The F key
Input.G = 6            --< The G key
Input.H = 7            --< The H key
Input.I = 8            --< The I key
Input.J = 9            --< The J key
Input.K = 10           --< The K key
Input.L = 11            --< The L key
Input.M = 12            --< The M key
Input.N = 13            --< The N key
Input.O = 14            --< The O key
Input.P = 15            --< The P key
Input.Q = 16            --< The Q key
Input.R = 17            --< The R key
Input.S = 18            --< The S key
Input.T = 19            --< The T key
Input.U = 20            --< The U key
Input.V = 21            --< The V key
Input.W = 22            --< The W key
Input.X = 23            --< The X key
Input.Y = 24            --< The Y key
Input.Z = 25            --< The Z key
Input.Num0 = 26         --< The 0 key
Input.Num1 = 27         --< The 1 key
Input.Num2 = 28         --< The 2 key
Input.Num3 = 29         --< The 3 key
Input.Num4 = 30         --< The 4 key
Input.Num5 = 31         --< The 5 key
Input.Num6 = 32         --< The 6 key
Input.Num7 = 33         --< The 7 key
Input.Num8 = 34         --< The 8 key
Input.Num9 = 35         --< The 9 key
Input.Escape = 36       --< The Escape key
Input.LControl = 37     --< The left Control key
Input.LShift = 38       --< The left Shift key
Input.LAlt = 39         --< The left Alt key
Input.LSystem = 40      --< The left OS specific key: window (Windows and Linux) = 0 apple (MacOS X) = 0 ...
Input.RControl = 41     --< The right Control key
Input.RShift = 42       --< The right Shift key
Input.RAlt = 43         --< The right Alt key
Input.RSystem = 44      --< The right OS specific key: window (Windows and Linux) = 0 apple (MacOS X) = 0 ...
Input.Menu = 45         --< The Menu key
Input.LBracket = 46     --< The [ key
Input.RBracket = 47     --< The ] key
Input.Semicolon = 48    --< The ; key
Input.Comma = 49        --< The  = 0 key
Input.Period = 50       --< The . key
Input.Quote = 51        --< The ' key
Input.Slash = 52        --< The / key
Input.Backslash = 53    --< The \ key
Input.Tilde = 54        --< The ~ key
Input.Equal = 55        --< The = key
Input.Hyphen = 56       --< The - key (hyphen)
Input.Space = 57        --< The Space key
Input.Enter = 58        --< The Enter/Return keys
Input.Backspace = 59    --< The Backspace key
Input.Tab = 60          --< The Tabulation key
Input.PageUp = 61       --< The Page up key
Input.PageDown = 62     --< The Page down key
Input.End = 63          --< The End key
Input.Home = 64         --< The Home key
Input.Insert = 65       --< The Insert key
Input.Delete = 66       --< The Delete key
Input.Add = 67          --< The + key
Input.Subtract = 68     --< The - key (minus = 0 usually from numpad)
Input.Multiply = 69     --< The * key
Input.Divide = 70       --< The / key
Input.Left = 71         --< Left arrow
Input.Right = 72        --< Right arrow
Input.Up = 73           --< Up arrow
Input.Down = 74         --< Down arrow
Input.Numpad0 = 75      --< The numpad 0 key
Input.Numpad1 = 76      --< The numpad 1 key
Input.Numpad2 = 77      --< The numpad 2 key
Input.Numpad3 = 78      --< The numpad 3 key
Input.Numpad4 = 79      --< The numpad 4 key
Input.Numpad5 = 80      --< The numpad 5 key
Input.Numpad6 = 81      --< The numpad 6 key
Input.Numpad7 = 82      --< The numpad 7 key
Input.Numpad8 = 83      --< The numpad 8 key
Input.Numpad9 = 84      --< The numpad 9 key
Input.F1 = 85           --< The F1 key
Input.F2 = 86           --< The F2 key
Input.F3 = 87           --< The F3 key
Input.F4 = 88           --< The F4 key
Input.F5 = 89           --< The F5 key
Input.F6 = 90           --< The F6 key
Input.F7 = 91           --< The F7 key
Input.F8 = 92           --< The F8 key
Input.F9 = 93           --< The F9 key
Input.F10 = 94          --< The F10 key
Input.F11 = 95          --< The F11 key
Input.F12 = 96          --< The F12 key
Input.F13 = 97          --< The F13 key
Input.F14 = 98          --< The F14 key
Input.F15 = 99          --< The F15 key
Input.Pause = 100        --< The Pause key

Input.KeyCount = 101     --< Keep last -- the total number of keyboard keys

-- Deprecated values:

Input.Dash      = Input.Hyphen       --< \deprecated Use Hyphen instead
Input.BackSpace = Input.Backspace    --< \deprecated Use Backspace instead
Input.BackSlash = Input.Backslash    --< \deprecated Use Backslash instead
Input.SemiColon = Input.Semicolon    --< \deprecated Use Semicolon instead
Input.Return    = Input.Enter         --< \deprecated Use Enter instead

return Input
