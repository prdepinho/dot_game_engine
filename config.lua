
resolutions = {
  nes = {
    width = 256,
    height = 240,
  },
  -- 4:3
  vga = {
    width = 640,
    height = 480,
  },
  svga = {
    width = 800,
    height = 600,
  },
  xga = {
    width = 1024,
    height = 768,
  },
  -- 8:9
  wvga = {
    width = 768,
    height = 480,
  },
  -- 16:9
  fwvga = {
    width = 854,
    height = 480,
  },
  pal = {
    width = 1024,
    height = 576,
  },
}

screen_resolution = resolutions.vga

fullscreen = false
-- Use when not in fullscreen. Increase the window size this many times its resolution.
size_modifier = 2

-- use_vsync and limit_framerate should not be used together.
use_vsync = false
limit_framerate = not use_vsync

-- This option takes effect if limit_framerate is true.
set_framerate = 120

-- game volume: from 0 (silent) to 100 (full volume)
music_volume = 15
sound_volume = 15
