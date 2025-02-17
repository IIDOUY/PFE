# Generated by Django 5.1.4 on 2025-02-16 22:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0004_rename_service_id_link_service'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='rating',
            name='rating',
        ),
        migrations.AddField(
            model_name='rating',
            name='stars',
            field=models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5')], default=0),
        ),
    ]
