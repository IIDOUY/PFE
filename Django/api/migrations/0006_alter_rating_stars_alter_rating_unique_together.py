# Generated by Django 5.1.4 on 2025-02-17 13:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0005_remove_rating_rating_rating_stars'),
    ]

    operations = [
        migrations.AlterField(
            model_name='rating',
            name='stars',
            field=models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5')], default=1),
        ),
        migrations.AlterUniqueTogether(
            name='rating',
            unique_together={('user', 'provider')},
        ),
    ]
