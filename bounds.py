from util import *

# load all config
config = load_config()

screen_bounds = load_screen_bounds()
log(f'screen_bounds: {screen_bounds}')

current_bounds = json.loads(os.getenv('current_bounds'))
log(f'current_bounds: {current_bounds}')

which_screen, percentX, percentY, percentW, percentH = load_input_actions(config)

new_bounds = get_new_bounds(screen_bounds[which_screen], percentX, percentY, percentW, percentH)

print(f"{new_bounds['x']} {new_bounds['y']} {new_bounds['width']} {new_bounds['height']}")