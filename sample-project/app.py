from flask import Flask, render_template, jsonify

app = Flask('sample app')


@app.route('/')
def index():
    return render_template('main.html')


@app.route('/items')
def items():
    return jsonify({'name': 'Sample app sample data',
                    'items': [{'id': 1, 'name': 'A thing'},
                              {'id': 2, 'name': 'Another thing'}]})


if __name__ == '__main__':
    app.debug = True
    app.run()
