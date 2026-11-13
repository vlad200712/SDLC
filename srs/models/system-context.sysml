// Контекстная диаграмма: система AutoService, роли пользователей и внешние сервисы.
package SystemContext {
    private import UiLibrary::*;

    part contextDiagram : Screen {
        attribute :>> width = 1480;
        attribute :>> height = 780;
        attribute :>> caption = "Контекст системы AutoService";

        part client : Actor { attribute :>> posX = 120; attribute :>> posY = 120; attribute :>> caption = "Клиент СТО"; }
        part master : Actor { attribute :>> posX = 120; attribute :>> posY = 330; attribute :>> caption = "Мастер СТО"; }
        part admin : Actor { attribute :>> posX = 120; attribute :>> posY = 540; attribute :>> caption = "Администратор СТО"; }

        part autoservice : Block {
            attribute :>> posX = 310; attribute :>> posY = 40; attribute :>> width = 760; attribute :>> height = 680;
            attribute :>> caption = "Система AutoService";

            part mobileApp : Block {
                attribute :>> posX = 50; attribute :>> posY = 230; attribute :>> width = 230; attribute :>> height = 130;
                attribute :>> caption = "Мобильный клиент";
                attribute :>> subcaption = "Qt Quick / C++17";
            }
            part localCache : Block {
                attribute :>> posX = 50; attribute :>> posY = 470; attribute :>> width = 230; attribute :>> height = 120;
                attribute :>> caption = "Локальный кэш";
                attribute :>> subcaption = "SQLite";
            }
            part cloudApi : Block {
                attribute :>> posX = 460; attribute :>> posY = 230; attribute :>> width = 240; attribute :>> height = 130;
                attribute :>> caption = "Сервер Cloud API";
                attribute :>> subcaption = "REST / JWT";
            }
            part serverDb : Block {
                attribute :>> posX = 460; attribute :>> posY = 470; attribute :>> width = 240; attribute :>> height = 120;
                attribute :>> caption = "База данных";
                attribute :>> subcaption = "PostgreSQL";
            }
        }

        part vinApi : Block {
            attribute :>> posX = 1190; attribute :>> posY = 110; attribute :>> width = 240; attribute :>> height = 120;
            attribute :>> caption = "NHTSA VIN API";
            attribute :>> subcaption = "Декодирование VIN";
            attribute :>> tone = "external";
        }
        part pushService : Block {
            attribute :>> posX = 1190; attribute :>> posY = 320; attribute :>> width = 240; attribute :>> height = 120;
            attribute :>> caption = "Сервис Push-уведомлений";
            attribute :>> subcaption = "FCM / APNs";
            attribute :>> tone = "external";
        }
        part currencyApi : Block {
            attribute :>> posX = 1190; attribute :>> posY = 530; attribute :>> width = 240; attribute :>> height = 120;
            attribute :>> caption = "API курсов валют";
            attribute :>> subcaption = "BYN / USD";
            attribute :>> tone = "external";
        }

        connection clientLink : Link connect client to autoservice.mobileApp;
        connection masterLink : Link connect master to autoservice.mobileApp;
        connection adminLink : Link connect admin to autoservice.mobileApp;

        connection cacheLink : Link connect autoservice.mobileApp to autoservice.localCache { attribute :>> caption = "история / кэш"; }
        connection apiLink : Link connect autoservice.mobileApp to autoservice.cloudApi { attribute :>> caption = "HTTPS + JWT"; }
        connection dbLink : Link connect autoservice.cloudApi to autoservice.serverDb { attribute :>> caption = "SQL-запросы"; }

        connection vinLink : Link connect autoservice.cloudApi to vinApi { attribute :>> caption = "REST / VIN"; }
        connection pushLink : Link connect autoservice.cloudApi to pushService { attribute :>> caption = "уведомления"; }
        connection rateLink : Link connect autoservice.cloudApi to currencyApi { attribute :>> caption = "курсы валют"; }
    }
}
