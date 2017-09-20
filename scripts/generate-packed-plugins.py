import os
import json

plugins = []
for f in os.listdir("./dist/plugins"):
    if f != "packed":
        plugins.append(json.load(open("./dist/plugins/{}/{}.json".format(f,f))))

js = ""
css = ""
for plugin in plugins:
    if "js" in plugin:
        js += open("./dist{}".format(plugin['js']), "r").read()
        js += "\n";
        del plugin["js"]
    if "css" in plugin:
        css += open("./dist{}".format(plugin['css']), "r").read()
        css += "\n";
        del plugin["css"]

os.makedirs("./dist/plugins/packed", exist_ok=True)

plugins_js_file = open("./dist/plugins/packed/plugins.js", "w")
plugins_js_file.write(js)
plugins_js_file.close()

plugins_css_file = open("./dist/plugins/packed/plugins.css", "w")
plugins_css_file.write(css)
plugins_css_file.close()

packedPlugin = {
    "isPack": True,
    "js": "/plugins/packed/plugins.js",
    "css": "/plugins/packed/plugins.css",
    "plugins": plugins
}

plugins_json_file = open("./dist/plugins/packed/packed.json", "w")
json.dump(packedPlugin, plugins_json_file)
plugins_json_file.close()
