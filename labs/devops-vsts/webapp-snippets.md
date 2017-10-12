
## index.pug
Replace the contents of **views\index.pug** with the following text:

```pug
extends layout

block content
  .header
    a
      img(src='https://assets.onestore.ms/cdnfiles/external/uhf/long/9a49a7e9d8e881327e81b9eb43dabc01de70a9bb/images/microsoft-gray.png')

  //- nav.navbar.navbar-inverse.navbar-fixed-top
  nav.navbar.navbar-inverse

    .container

      .navbar-header
     
        button.navbar-toggle.collapsed(type='button', data-toggle='collapse', data-target='#navbar', aria-expanded='false', aria-controls='navbar')

          span.sr-only Toggle navigation

          span.icon-bar

          span.icon-bar

          span.icon-bar

        a.navbar-brand(href='#') Sample Node.js Application

      #navbar.navbar-collapse.collapse

        form.navbar-form.navbar-right

          fieldset.form-group

            input.form-control(type='text', placeholder='Email')

          fieldset.form-group

            input.form-control(type='password', placeholder='Password')

          button.btn.btn-success(type='submit') Sign in

  .jumbotron

    .container

      h1 Hello, world!

      p

        | This is a simple Node.js Express application.

      p

        a.btn.btn-primary.btn-lg(href='#', role='button') Learn more »

  .container

    .row

      .col-md-4

        h2 System Information

        p

          table 
              tr 
                td OS: 
                td #{info.type} &ndash; v#{info.release}
              tr
                td Hostname:
                td #{info.hostname} 
              tr
                td CPUs: 
                td #{info.cpus.length} &times; #{info.cpus[0].model}
              tr
                td Memory: 
                td #{Math.round(info.mem/(1024*1024))} Mb
              tr
                td Environment: 
                td #{info.env}  

        p

      .col-md-4

        h2 Heading

        p

          | Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.

        p

          a.btn.btn-default(href='#', role='button') View details »

      .col-md-4

        h2 Heading

        p

          | Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.

        p

          a.btn.btn-default(href='#', role='button') View details »

    hr
```

## layout.pug
Replace the contents of **views\layout.pug** with the following text:

```pug
doctype html
html
  head
    title= title
    link(href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css", rel="stylesheet", integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u", crossorigin="anonymous")
    link(rel='stylesheet', href='/stylesheets/style.css')
  body
    block content

  footer.footer
    .container
      p © Microsoft Corporation 2017
```

## style.css
Replace the contents of **public\stylesheets\style.css** with the following text:

```css
body {
    padding-top: 10px;
    padding-bottom: 20px;
    margin-bottom: 60px;
}

.header > a > img {
    display: block;
    padding: 0px 15px 12.5px;
    width: 150px;
}

.navbar {
    margin-bottom: 20px;
    border-radius: 0px;
}

.navbar-inverse {
    background-color: #0078D7;;
    border-color: #0078D7;
}

.navbar-inverse .navbar-brand {
    color: #ffffff;
}

.navbar-form .form-control {
    display: inline-block;
    width: auto;
    vertical-align: middle;
    margin: 3px;
}

.footer {
    position: absolute;
    bottom: 0;
    width: 100%;
    height: 60px;
    background-color: #f5f5f5;
    padding: 10px;
}

.footer .container .p {
    margin-top: 10px;
}
```