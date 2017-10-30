<img src="pics/logo.png" height=80 />

> The user community where you win by caring about your city. Explore your city and warn about the issues in your surroundings. Be actively engaged by supporting other citizens so that your local institutions can resolve them. In addition, you will get rewards for your commitment!

***Civify*** was a group project for [Software Engineering Project](https://www.fib.upc.edu/en/studies/bachelors-degrees/bachelor-degree-informatics-engineering/curriculum/syllabus/PES) @ UPC BarcelonaTech - Barcelona School of Informatics done by seven students ([@dsegoviat](https://github.com/dsegoviat), [@sergiosanchis](https://github.com/sergiosanchis), [@IvanDeMingo](https://github.com/IvanDeMingo), [@Alcasser](https://github.com/Alcasser), [@carleslc](https://github.com/carleslc), [@ricardfos](https://github.com/ricardfos) & [@ArnauBlanch](https://github.com/ArnauBlanch)).
# Civify: API
## Features
* Issues: create, update, delete, get issues (info & photo) with filters (by location, user...), confirm, mark as resolved & report
* Users: registration, login, get user info, update info, get coins + rewards + badges, password recovery (e-mail with web link)
* Achievements & Events: create, update, get, delete, claim reward
* Rewards: create, update, get, delete, exchange reward

This REST API was developed using Ruby on Rails (ActiveModel, ActionMailer, Paperclip, Capistrano...). It interacted with the [Civify app](https://github.com/ArnauBlanch/civify-app) and [Civify web](https://github.com/ArnauBlanch/civify-web). It is tested with Rubocop.

---
**App repo:** https://github.com/ArnauBlanch/civify-app

**Web repo:** https://github.com/ArnauBlanch/civify-web
